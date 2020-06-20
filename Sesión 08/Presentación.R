# ------------------------------- Script ----------------------------------
#                     Universidad Nacional de Colombia
#                     Facultad de Ciencias Económicas
#                              Econometría I
# ------------------------------ Monitoria --------------------------------
# 1. Hernando Hernandez Lasso.
# 2. Julián David Rojas Aguilar.

# ---------------------------- Instrucciones ------------------------------
# 1. Cada línea en el script se ejecuta con Ctrl + Enter o con el botón run de 
#    esta ventana.
# 2. Todo el texto que se encuentre después del numeral (#) es un comentario.
# 3. A la hora de ejecutar cada línea, R no tendrá en cuenta los comentarios.
# 4. Todos los resultados de comandos ejecutados se muestran en la consola.
# 5. Es posible ejecutar comandos directamente desde la consola con la tecla 
#    Enter.

# Preparación -------------------------------------------------------------
setwd("~/GitHub/Introduction-to-Econometrics/Sesión 08")
rm(list = ls())
library(readr)
library(tidyverse)
library(lrmest)
library(stargazer)

# Importación -------------------------------------------------------------
Datos <- as.data.frame(read_csv("Cornwell & Rupert (1988).csv"))

# Variables ===============================================================
# - EXP : Experiencia.
# - WKS : Semanas trabajadas.
# - OCC : Ocupación, =1 si es trabajador de cuello azul, =0 en otro caso.
# - IND : Industria, =1 si es trabajador industrial, =0 en otro caso.
# - SOUTH : =1 si reside en el sur, =0 en otro caso.
# - SMSA  : =1 si reside en una ciudad, =0 en otro caso.
# - MS    : =1 si es casado, =0 en otro caso.
# - FEM   : =1 si es mujer, =0 en otro caso.
# - UNION : =1 si pertenece al sindicato, =0 en otro caso.
# - ED    : Años de educación.
# - BLK   : =1 si es negro, =0 en otro caso.
# - LWAGE : Logaritmo del salario.

# Creación de dummies -----------------------------------------------------
# 1. Logros educativos ----------------------------------------------------
Datos.Logros = Datos %>%
  add_column(LTHS    = if_else(Datos$ED <= 11, 1, 0),
             HS      = if_else(Datos$ED == 12, 1, 0),
             COLLEGE = if_else(13 <= Datos$ED & Datos$ED <= 16, 1, 0),
             POSGRAD = if_else(Datos$ED == 17, 1, 0))
  
# 2. Spline ---------------------------------------------------------------
Datos.Spline = Datos %>%
  add_column(LTHS    = if_else(Datos$ED <= 11, 1, 0),
             HS      = if_else(Datos$ED <= 12, 1, 0),
             COLLEGE = if_else(Datos$ED <= 16, 1, 0),
             POSGRAD = if_else(Datos$ED <= 17, 1, 0))

# Regresiones -------------------------------------------------------------
# 1. Extendida ------------------------------------------------------------
Regresión.M1 <- lm(LWAGE ~ EXP + I(EXP^2) + WKS + OCC + IND + SOUTH +
                     SMSA + MS + UNION + FEM + ED + BLK, data = Datos.Logros)
summary(Regresión.M1)

# 2. Logros educativos extendida ------------------------------------------
# En los términos de igualdad se está creando colinealidad perfecta.
Regresión.M2 <- lm(LWAGE ~ EXP + I(EXP^2) + WKS + OCC + IND + SOUTH +
                     SMSA + MS + UNION + FEM + BLK + ED + HS + COLLEGE +
                     POSGRAD + I(HS*ED) + I(COLLEGE*ED) + I(POSGRAD*ED), 
                   data = Datos.Logros)
summary(Regresión.M2)

# 2.1. Visualización ------------------------------------------------------
Datos.Logros = Datos.Logros %>%
  mutate(Logros = case_when(LTHS == 1 ~ 'Primaria',
                                HS == 1  ~ 'Secundaria', 
                                COLLEGE == 1 ~ 'Pregrado',
                                POSGRAD == 1 ~ 'Posgrado'),
             Logros = factor(Logros, levels = c('Primaria', 'Secundaria', 
                                                'Pregrado', 'Posgrado')))

ggplot(Datos.Logros, aes(x = ED, y = LWAGE, colour = Logros)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(title = "Modelo minceriano", 
       subtitle = "Comparación por logros educativos",
       x = "Años de educación",
       y = "Salario") + 
  theme_bw() +
  theme(plot.title = element_text(size = 12, face = "bold"),
        plot.subtitle = element_text(face = 'italic'),
        legend.position = 'bottom',
        legend.box.background = element_rect(),
        legend.box.margin = margin(6, 6, 6, 6))

# 3. Spline extendida -----------------------------------------------------
# Se define los umbrales a utilizar.
Datos.Spline = Datos.Spline %>%
  add_column(Educación.Secundaria = Datos.Spline$ED - 12,
             Educación.Pregrado   = Datos.Spline$ED - 16,
             Educación.Posgrado   = Datos.Spline$ED - 17)

Regresión.M3 <- lm(LWAGE ~ EXP + I(EXP^2) + WKS + OCC + IND + SOUTH +
                     SMSA + MS + UNION + FEM + BLK + ED + 
                     I(HS*Educación.Secundaria) + I(COLLEGE*Educación.Pregrado) + 
                     I(POSGRAD*Educación.Posgrado), data = Datos.Spline)
summary(Regresión.M3)

# Presentación ------------------------------------------------------------
stargazer(Datos, type = "text", title = "Estadística descriptiva", digits = 2)
stargazer(Regresión.M1, Regresión.M2, Regresión.M3, type = "text",
          title = 'Comparación de las regresiones', digits = 2,
          column.labels = c('Extendido', 'Extendido con logros educativos', 'Spline extendido'))

# Versión de LaTeX:
stargazer(Regresión.M1, Regresión.M2, Regresión.M3, type = "latex",
          title = 'Comparación de las regresiones', digits = 2,
          column.labels = c('Extendido', 'Extendido con logros educativos', 'Spline extendido'))
