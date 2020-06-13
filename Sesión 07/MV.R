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
setwd("~/GitHub/Introduction-to-Econometrics/Sesión 07")
library(readr)
library(stats4)  # Permite usar mle. 
library(methods)
library(emdbook)
library(bbmle)   # Permite usar mle2.
set.seed(1001)

# Primer ejemplo ----------------------------------------------------------
# 1| Simulación -----------------------------------------------------------
Observaciones = 100
Independiente = rnorm(Observaciones, 
                      mean = 7, 
                      sd = 2)
Dependiente   = rnorm(length(Independiente),
                      mean = 1 + 2 * Independiente, 
                      sd = 1)
plot(Dependiente ~ Independiente)

# 2| Estimación MCO -------------------------------------------------------
Modelo.MCO <- lm(Dependiente ~ Independiente)
summary(Modelo.MCO)
confint(Modelo.MCO) # Intervalos de confianza paramétricos.
vcov(Modelo.MCO)    # Matriz de varianzas y covarianzas del modelo.
                    # Las raíces de la diagonal son los errores estándar.
sqrt(diag(vcov(Modelo.MCO)))

# Se puede obtener algunos valores para comparar con el método de MV.
logLik(Modelo.MCO)
AIC(Modelo.MCO)
BIC(Modelo.MCO)

# 3| Estimación MV --------------------------------------------------------
# mle2() es una 'envoltura' (wrapper) para para la función optim().
# Se asume una distribución log-normal.
Regresión.MV <- function(Beta0, Beta1, Sigma) {
  Y.Predicha = Beta0 + Beta1 * Independiente
  -sum(dnorm(Dependiente, mean = Y.Predicha, sd = Sigma, log = T))
}

# Se puede jugar con los valores iniciales que se asigne.
Modelo.MV <- mle2(Regresión.MV, 
                  start  = list(Beta0 = 10, Beta1 = 10, Sigma = 10))

warnings() # Las advertencias tienen que ver con los valores que no puede tomar
           # la varianza, por ejemplo. Si se utiliza un valor no-positivo
           # entonces el cálculo va a fallar.
Modelo.MV <- mle2(Regresión.MV, 
                  start  = list(Beta0 = 10, Beta1 = 10, Sigma = 10),
                  method = 'L-BFGS-B',
                  lower  = c(Beta0 = -Inf, Beta1 = -Inf, Sigma = 0.001), 
                  upper  = c(Beta0 =  Inf, Beta1 =  Inf, Sigma = Inf))
summary(Modelo.MV)

# Para comparar con los resultados anteriores:
logLik(Modelo.MV)   # La mostrada por el resumen es dos veces la log-likelihood.
                    # df muestra cuántos parámetros han sido estimados.
deviance(Modelo.MV)
confint(Modelo.MV)  # El perfilamiento puede demorarse a veces y es buena
                    # idea guardar los resultados.
warnings()
Profile.Modelo.MV <- profile(Modelo.MV)
confint(Profile.Modelo.MV)

# Graficando el perfil no se debe encontrar curvas extrañas, pues eso
# sugeriría que las funciones no son monótonas. En este caso, los valores
# iniciales pueden llevar a máximos locales y no globales.
par(mfrow = c(1, 3)) # Una columna para cada uno de los parámetros.
plot(Profile.Modelo.MV, abs = T, conf = 1/100 * c(50, 80, 90, 95, 99)) # Se utiliza los los valores absolutos de la VF.
                                                                       # Sigma luce sensible a los valores iniciales por sus restricciones.
par(mfrow = c(1, 1))

vcov(Modelo.MV) # Matriz de información de Fisher.
sqrt(diag(vcov(Modelo.MV))) # Nótese los errores estándar más pequeños.
diag(solve(Modelo.MV@details$hessian))

# Segundo ejemplo ---------------------------------------------------------
# 1| Importación ----------------------------------------------------------
# Se importa la matriz creada en el ejercicio de GEIH.
setwd("~/GitHub/Introduction-to-Econometrics/Sesión 07")
write.csv(Datos, file = 'Ejemplo.csv', 
          col.names = TRUE, row.names = FALSE, append = FALSE) # Habiendo cargado los datos de la GEIH.
Ejemplo <- read_csv("Ejemplo.csv")                             # Importando la exportación previa.
Ejemplo <- Datos                                               # Sobreescribe el código escrito antes.

# 2| Estimación por MCO ---------------------------------------------------
Modelo.MCO <- lm(`Ln(Salario por hora)` ~ Escolaridad + 
                   `Experiencia Potencial` + 
                   I(`Experiencia Potencial`^2), data = Ejemplo)
summary(Modelo.MCO)
coef(Modelo.MCO)
confint(Modelo.MCO)
logLik(Modelo.MCO)

# Visualización de la matriz de diseño:
head(model.matrix(Modelo.MCO))
tail(model.matrix(Modelo.MCO))
Matriz.Diseño <- with(data = Ejemplo, model.matrix(~ Escolaridad + 
                                                     `Experiencia Potencial` + 
                                                     I(`Experiencia Potencial`^2)))

# 3| Estimación por MV ----------------------------------------------------
Regresión.MV <- function(Beta0, Beta1, Beta2, Beta3, Sigma, Datos = Matriz.Diseño) {
  Y.Predicha = Beta0 * Datos[ , 1] + Beta1 * Datos[ , 2] + Beta2 * Datos[ , 3] + Beta3 * Datos[ , 4] 
  -sum(dnorm(Ejemplo$`Ln(Salario por hora)`, mean = Y.Predicha, sd = Sigma, log = T))
}

# Chequeo inicial:
Regresión.MV(1, 1, 1, 1, 1, Matriz.Diseño)
Regresión.MV(2, 2, 2, 2, 2, Matriz.Diseño)

# Elección de los valores iniciales:
Inicial.Beta0 <- mean(Ejemplo$`Ln(Salario por hora)`)
Inicial.Sigma <- sd(Ejemplo$`Ln(Salario por hora)`)   # Sería mejor el error estándar.

# Estimación:
Modelo.MV <- mle2(Regresión.MV,
                  start = list(Beta0 = Inicial.Beta0,
                               Beta1 = 0,
                               Beta2 = 0,
                               Beta3 = 0,
                               Sigma = Inicial.Sigma),
                  method = 'L-BFGS-B', 
                  lower  = c(Beta0 = -Inf, Beta1 = -Inf, Beta2 = -Inf, Beta3 = -Inf, Sigma = 0.001), 
                  upper  = c(Beta0 =  Inf, Beta1 =  Inf, Beta2 =  Inf, Beta3 =  Inf, Sigma = Inf))

# Comparación:
summary(Modelo.MV)
summary(Modelo.MCO)

Profile.Modelo.MV <- profile(Modelo.MV)
confint(Profile.Modelo.MV)
par(mfrow = c(1, 3))
plot(Profile.Modelo.MV, abs = T, conf = 1/100 * c(50, 80, 90, 95, 99)) 
par(mfrow = c(1, 1))

vcov(Modelo.MV)
sqrt(diag(vcov(Modelo.MV)))
diag(solve(Modelo.MV@details$hessian))

# 4| Prueba LR ------------------------------------------------------------
Regresión.MV.Reducida <- function(Beta0, Sigma, Datos = Matriz.Diseño) {
  Y.Predicha = Beta0 
  -sum(dnorm(Ejemplo$`Ln(Salario por hora)`, mean = Y.Predicha, sd = Sigma, log = T))
}

Modelo.MV.Reducido <- mle2(Regresión.MV.Reducida,
                           start = list(Beta0 = Inicial.Beta0,
                                        Sigma = Inicial.Sigma))
summary(Modelo.MV.Reducido)
LR = deviance(Modelo.MV.Reducido) - deviance(Modelo.MV)
LR
pchisq(LR, df = 1, lower.tail = F) # Solo hay un parámetro de diferencia.
