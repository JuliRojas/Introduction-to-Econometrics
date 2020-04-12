# ----------- Script -------------
# Universidad Nacional de Colombia
#  Facultad de Ciencias Económicas
#        Econometría I
# --------- Monitoría ------------
# 1. Federico Medina
# 2. Julián Rojas

# --------- Instrucciones --------
# 1. Cada línea en el script se ejecuta con Ctrl + Enter o con el botón run de 
#    esta ventana.
# 2. Todo el texto que se encuentre después del numeral (#) es un comentario.
# 3. A la hora de ejecutar cada línea, R no tendrá en cuenta los comentarios.
# 4. Todos los resultados de comandos ejecutados se muestran en la consola.
# 5. Es posible ejecutar comandos directamente desde la consola con la tecla 
#    Enter.

# ---- 1 | R como calculadora -------
# Note que el resultado aparece en la consola, que es la ventana inferior.

(90/4)^3
# Módulo
24%%7
# Uso del número pi
pi*100
# Valor absoluto
abs(-4.8)
# Redondeo
round(6.72)
# Redondeo con 'n' decimales
round(4.56666,1)
# Eliminar decimales
trunc(7.888)
# Raíz cuadrada
sqrt(81)
# Funciones trigonométricas
sin(90)
# Funciones logarítmicas 
log(15)
# Operaciones compuestas
round(log(abs(-97)))

# ---- 2 | Creación de objetos/variables ----
# Note que los objetos creados aparecen en el "Enviroment" del WorkSpace.
# Para crear objetos se usa el operador "=" o el operador "<-".

# Se crea un objeto llamado "a" que sea igual a 5.
a = 5
# Se imprime o muestra el objeto creado.
a
# Se crea un objeto llamado "b" que sea igual a 4 y, a su vez, se imprime.
b <- 4; b
# Se opera con los objetos creados. Esto es, se crea un nuevo objeto "c" 
# que sea la multiplicación de "a" y "b", y se imprime "c".
c = a*b+b^2
c

# --- 2.1 Tipos de variables -----

# Se crea un objeto llamado "mi.variable.caracter" y que contenga la palabra 
# "Manzana".
mi.variable.caracter = "Manzana"
# Se muestra o imprime mi.variable.caracter
mi.variable.caracter

# Crear un objeto llamado "mi.variable.logica", que sea verdadera.
mi.variable.logica = TRUE
mi.variable.logica

#  ---- 2.2 Comparaciones/Operaciones lógicas ----
# El resultado de estas operaciones será verdadero o falso.

# Se crea un objeto "a" que sea igual a 4 y uno llamado "b" que sea igual a 3.
a=4 ; b=3
# Se prueba que "a" es mayor o igual a 5.
a <= 5
# O que es igual a:
a == 5
# O que es diferente a:
a != 5

# Con argumentos booleanos también puede operarse.
# Y (ambos deben ser verdaderos).
a>0 & b>5
# O (uno debe ser verdadero).
a>0 | b>1
# Negación.
! a<0

# ---------- 3 | Vectores ------------
# ---- 3.1 Creación de vectores -----

# Se crea un vector "d" con los números 4, 7, 11 y 16 con la función concatenar c().
d = c(4, 7, 1, 16)
# Se muestra el vector "d" en la consola.
d

# Se crea un vector "e" como una secuencia que avanza de uno en uno.
e = 0:100
# Se imprime (o muestra en la consola) el vector "e".
e

# Se crea un vector "f" como una secuencia que no avance de uno en uno con seq() 
# En sus argumentos, estará el límite inferior, el límite superior, y la escala
# en la cual aumenta la secuencia. En este caso, es una secuencia de 1 a 8 que 
# aumenta en 0.5.
f = seq(1,8,0.5)
# Se imprime f.
f

# Se crea un vector de datos que se repiten un dado número de veces con la 
# función rep().
rep(14,8)     # Vector en el que el 14 se repite 8 veces.
rep("A",5)    # Vector en el que la "A" se repite 5 veces.
dummy = c(rep(0,10),rep(1,10),rep(0,10))
dummy

# --- 3.2 Funciones en vectores -----

# Crear e imprimir un vector "h" que va de 6 a 10 y avanza de uno en uno.
h = 6:10
h
# Suma de vectores.
h+h
h+10
# Multiplicar un vector por una constante.
h*4
# Aplicar potencia a un vector.
h^2
# Aplicar logaritmo a un vector.
log(h)
# Suma de los elementos de un vector.
sum(h)
# Producto de los elementos de un vector.
prod(h)

# Máximo de un vector.
max(h)
# Mínimo de un vector.
min(h)
# Media de un vector.
mean(h)
# Número total de elementos del vector.
length(h)

# Mostrar sólo ciertos elementos de un vector.
# En R la indexación empieza desde el 1.
h[3]          # Se extrae el elemento de la posición 3.
h[length(h)]  # O el de la última posición
# Se muestra los elementos de la posición 2, 3 y 5.
h[c(2,3,5)]

# Se elimina números de determinadas posiciones en un vector.
h[-c(1,5)]  # Se eliminó los datos de la posición 1 y 5.

# ---- 3.3 Otras funciones de vectores ------

# Se crea otro vector.
j <- c(-1, 2, 6, 7, 4, 5, 2, 9, 3, 6, 4, 3); j  

sort(j)                     # Ordena un vector de menor a mayor.
sort(j, decreasing = TRUE)  # Ordena un vector de mayor a menor.
unique(j)                   # Muestra los datos únicos del vector.

# Vectores lógicos.
j > 0       # Se ve qué elementos de j son positivos.
k = log(j)  # Se crea un vector k que es el logaritmo natural de j.
k

# ---- 3.4 Modificar valor(es) de un vector ----

k[1]                  # Ver el elmento 1 del vector k.
mean(k)               # Hallar la media del vector k
mean(k,na.rm = TRUE)  # Hallar la media del vector k excluyendo NA's.
k[1] = 99             # Editar el NA de k
k

# ------ 4 | Matrices -----------

# ----- 4.1 Crear matrices ------

# Se especifica los elementos que contendrá la matriz, es decir, la extensión 
# del vector a dos dimensiones. Posteriormente, se indica el número de filas que 
# se desea (nrow) y el número de columnas (ncol). Así mismo, puede mencionarse 
# cómo se quiere que se enlisten los elementos en la matriz, si por columna 
# byrow = F, o por filas byrow = T.
matriz1 = matrix(1:12, nrow = 3, byrow = T)

# ----- 4.2 Operaciones con matrices -----

matriz1 + matriz1     # Suma de matrices.
matriz1 + 20          # Sumar una constante.
matriz1*0.5           # Multiplicar por constante.
matriz1*matriz1       # Multiplicación de elementos uno a uno.
matriz1%*%t(matriz1)  # Verdadera multiplicación de matrices, donde:
t(matriz1)            # Transpuesta.

dim(matriz1)  # Dimensiones de una matriz
nrow(matriz1) # Número de filas de una matriz
ncol(matriz1) # Número de columnas de una matriz

# ---- 4.3 Manipulación de matrices ------

matriz1[3,4]     # Mostrar el elemento de determinada posición.
# En este caso, tercera fila, cuarta columna.

matriz1[2,]     # Mostrar elementos de una fila
matriz1[,3]     # Mostrar elementos de una columna

# Crear matrices a partir de vectores.
k<-c(3,7,1,0,2,11)
# Bind traduce unir a, y r indicaría una unión de vectores filas, mientras
# que c permitiría una unión de vectores columna.
rbind(k, k^2)    # Une vectores uno debajo de otro.
cbind(k, k^3)    # Une vectores uno al lado de otro.

#Agregar nombres a una matriz
mat.1 <- rbind(1:4,5:8, 9:12)
mat.1
rownames(mat.1) = c("Auto","Motocicleta","Bici")
colnames(mat.1) = c("Azul","Verde","Rojo","Amarillo")
mat.1