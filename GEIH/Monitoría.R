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
rm(list = ls())
library(readr)
library(tidyverse)
library(gdata)
library(stargazer)

# Bases de datos ----------------------------------------------------------
setwd("C:/Users/judro/Documents/GitHub/Introduction-to-Econometrics/GEIH")
CaracterísticasGenerales <- read_delim("Area_Caracteristicas_Generales_Personas.csv", 
                                       ";", escape_double = FALSE, trim_ws = TRUE)
CaracterísticasOcupados <- read_delim("Area_Ocupados.csv", ";", 
                                      escape_double = FALSE, trim_ws = TRUE)

# 1| Manipulación ---------------------------------------------------------
# 1.1| Creación de los ID -------------------------------------------------
#      Se procede a cambiar los nombres de las variables consideradas como
#      apropiadas para la creación de las identificaciones, a saber:
#      - DIRECTORIO: ID.Vivienda
#      - ORDEN: ID.Persona
#      - SECUENCIA_P: ID.Hogar
# Para las Características Generales: A través de 
colnames(CaracterísticasGenerales)[which(colnames(CaracterísticasGenerales) == 'DIRECTORIO')] <- 'ID.Vivienda'
colnames(CaracterísticasGenerales)[which(colnames(CaracterísticasGenerales) == 'ORDEN')] <- 'ID.Persona'
colnames(CaracterísticasGenerales)[which(colnames(CaracterísticasGenerales) == 'SECUENCIA_P')] <- 'ID.Hogar'
# Para los Individuos Ocupados:
CaracterísticasOcupados <- rename.vars(CaracterísticasOcupados,
                                       from = c('DIRECTORIO', 'ORDEN', 'SECUENCIA_P'),
                                       to = c('ID.Vivienda', 'ID.Persona', 'ID.Hogar'))
# Luego, el ID único vendrá dado por:
CaracterísticasGenerales = CaracterísticasGenerales %>% 
  add_column(ID = paste(as.character(CaracterísticasGenerales$ID.Vivienda), 
                        as.character(CaracterísticasGenerales$ID.Hogar),
                        as.character(CaracterísticasGenerales$ID.Persona), 
                        sep = ''),
             .before = 1)
CaracterísticasOcupados = CaracterísticasOcupados %>% 
  add_column(ID = paste(as.character(CaracterísticasOcupados$ID.Vivienda), 
                        as.character(CaracterísticasOcupados$ID.Hogar),
                        as.character(CaracterísticasOcupados$ID.Persona), 
                        sep = ''),
             .before = 1)
# Se verifica que las llaves sean únicas:
length(CaracterísticasGenerales$ID) == length(unique(CaracterísticasGenerales$ID))
length(CaracterísticasOcupados$ID) == length(unique(CaracterísticasOcupados$ID))

# 1.2| Unión de las bases de datos ----------------------------------------
#      Se revisa los nombres que son idénticos en ambas bases de datos y se 
#      deja, solamente, los de 'CaracterísticasGenerales', pues es el
#      documento más extenso. Posee a todos los individuos.
intersect(names(CaracterísticasGenerales), names(CaracterísticasOcupados))
CaracterísticasOcupados = select(CaracterísticasOcupados, -c("ID.Vivienda", 
                                                             "ID.Hogar", 
                                                             "ID.Persona", 
                                                             "HOGAR", "REGIS", 
                                                             "AREA", "MES", 
                                                             "DPTO", 
                                                             "fex_c_2011"))
# Cualquiera de las uniones de los datos listadas a continuación es válida.
Datos = inner_join(x = CaracterísticasGenerales, 
                   y = CaracterísticasOcupados, 
                   by = 'ID')
Datos = merge(x = CaracterísticasGenerales, 
              y = CaracterísticasOcupados, 
              by = 'ID')

# 1.3| Selección de las variables -----------------------------------------
#      Finalmente, se selecciona las variables a trabajar, a saber:
#      -   p6800: Horas que trabaja a la semana.
#      -   p6850: Horas trabajadas la semana pasada.
#      -   p7045: Horas trabajadas en una labor secundaria a la semana.
#      - inglabo: Ingresos laborales mensuales.
#      -   p6040: Edad.
#      -     esc: Escolaridad.
#      -   p6020: Sexo.
Datos = select(Datos, 
               c('P6800', 'P6850', 'P7045', 'INGLABO', 'P6040', 'ESC', 'P6020'))
Datos = select(Datos, c('P6800', 'INGLABO', 'P6040', 'ESC', 'P6020'))
colnames(Datos) <- c('Trabajo semanal', 'Ingreso mensual', 
                     'Edad', 'Escolaridad', 'Sexo')

# Hay dos opciones para trabajar con el sexo, a saber:
# 1| Factores: Trabajemos con esta.
Datos = Datos %>% mutate(Sexo = case_when(Sexo == 1 ~ 'Hombre', Sexo == 2 ~ 'Mujer'),
                         Sexo = factor(Sexo, levels = c('Hombre', 'Mujer')))
# 2| Binarias: 
#    Datos = Datos %>% mutate(Sexo = case_when(Sexo == 1 ~ 1, Sexo == 2 ~ 0))

# Se procede a generar las variables de salario por hora y experiencia potencial.
Datos = Datos %>%
  add_column(`Salario por hora` = (Datos$`Ingreso mensual`*12)/(Datos$`Trabajo semanal`*52),
             `Experiencia Potencial` = Datos$Edad - Datos$Escolaridad - 5)
# Pueden analizarse un poco los datos, por ejemplo:
max(Datos$`Salario por hora`, na.rm = T)
min(Datos$`Salario por hora`, na.rm = T)
max(Datos$Escolaridad, na.rm = T)
min(Datos$Escolaridad, na.rm = T)

# Para no operar con logaritmo valores de cero (0), el logaritmo del salario
# irá con un 'case_when', como se mostraba previamente.
Datos = Datos %>% 
  mutate(`Ln(Salario por hora)` = case_when(`Ingreso mensual` > 1000  ~ log(`Salario por hora`), 
                                            `Ingreso mensual` <= 1000  ~ NA_real_))
# Se revisa cuántos datos se encontraban por debajo del umbral.
sum(is.na(Datos$`Ln(Salario por hora)`))
length(Datos$`Ln(Salario por hora)`) - sum(is.na(Datos$`Ln(Salario por hora)`))

# Se desecha los valores perdido:
Datos = as.data.frame(drop_na(Datos))

# 2| Regresión ------------------------------------------------------------
#    Ya con todas las variables necesarias creadas, se procede a realizar la
#    estimación.
RegresiónOriginal <- lm(`Ln(Salario por hora)` ~ Escolaridad + 
                          `Experiencia Potencial` + 
                          I(`Experiencia Potencial`^2), data = Datos)
summary(RegresiónOriginal)

RegresiónDiscriminación <- lm(`Ln(Salario por hora)` ~ Escolaridad + 
                                `Experiencia Potencial` + 
                                I(`Experiencia Potencial`^2) +
                                Sexo, data = Datos)
summary(RegresiónDiscriminación)

# 2.1| Presentación -------------------------------------------------------
#      Un poco de estadística descriptiva podría ser:
stargazer(Datos, type = "text", title = "Estadística descriptiva", digits = 2)

# Así mismo, las diferencias entre las regresiones:
stargazer(RegresiónOriginal, RegresiónDiscriminación, type = "text",
          title = 'Comparación de las regresiones', digits = 2)
