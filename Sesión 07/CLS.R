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
setwd("~/GitHub/Introduction-to-Econometrics/Sesión 07")
rm(list = ls())
Datos <- read.table("(Mankiw et al., 1992).txt", header = TRUE)
N     <- matrix(Datos$N, ncol = 1)
lndY  <- matrix(log(Datos$Y85)-log(Datos$Y60), ncol = 1)
lnY60 <- matrix(log(Datos$Y60), ncol = 1)
lnI   <- matrix(log(Datos$invest/100), ncol = 1)
lnG   <- matrix(log(Datos$pop_growth/100+0.05), ncol = 1)
lnS   <- matrix(log(Datos$school/100), ncol = 1)
X     <- as.matrix(cbind(lnY60, lnI, lnG, lnS, matrix(data = 1, nrow = nrow(lndY), ncol = 1)))
X     <- X[N==1,]
Y     <- lndY[N==1]

# 1| Estimación vía MCO ---------------------------------------------------
Inversa              <- solve(t(X) %*% X)
Betas.OLS            <- Inversa %*% t(X) %*% Y
Estimación           <- X %*% Betas.OLS
Error                <- Y - Estimación
Varianza.Errores.OLS <- as.numeric((t(Error) %*% Error) * 1/(dim(X)[1] - dim(X)[2]))
Varianza.Betas.OLS   <- Varianza.Errores.OLS * (solve(t(X) %*% X))
SE.Betas.OLS         <- sqrt(diag(Varianza.Betas.OLS))
Betas.OLS
SE.Betas.OLS

# 2| Estimación vía CLS ---------------------------------------------------
R                  <- matrix(c(0, 1, 1, 1, 0), ncol = 1)
NuevaInversa       <- solve(t(R) %*% Inversa %*% R)
Betas.CLS          <- Betas.OLS - Inversa %*% R %*% NuevaInversa %*% (t(R) %*% Betas.OLS)
D                  <- Inversa %*% R %*% NuevaInversa
Complemento        <- diag(5) - D %*% t(R)
Varianza.Betas.CLS <- Complemento %*% Varianza.Betas.OLS %*% t(Complemento)
SE.Betas.CLS       <- sqrt(diag(Varianza.Betas.CLS))
Betas.CLS
SE.Betas.CLS