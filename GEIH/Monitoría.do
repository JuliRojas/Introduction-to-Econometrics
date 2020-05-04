* 					Universidad Nacional de Colombia
* 							Econometría I
* 		 				  Lectura del código
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* 							Preparación
* ------------------------------------------------------------------------------
* doedit "C:\Users\Julián Rojas\Desktop\Sueñito\Econometría\Monitoria\GEIH\Ejemplo - Profesor\Ejemplo.do" 	// Para abrir el documento base.
cd "C:\Users\Julián Rojas\Desktop\Sueñito\Econometría\Monitoria\GEIH\Ejemplo - Profesor\2010 - Enero (CSV)" // Directorio de trabajo.

* ------------------------------------------------------------------------------
* 							Ejercicio
* ------------------------------------------------------------------------------
* Se va a trabajar con dos bases de datos. 
* - Area_Caracteristicas_Generales_Personas.
* - Area_Ocupados.
* Sin embargo, se encuentran en un formato .csv, por lo que van a exportarse, 
* nuevamente, en este formato. Así, la siguiente sección se divide en:
* 1| Importación de los .csv y su transformación a .dta
* 2| Importación de Area_Ocupados.dta, para luego un merge.
* 3| Creación de las variables necesarias para la regresión.
* 4| Regresión.

* ------------------------------------------------------------------------------
* Primera parte:
* ------------------------------------------------------------------------------
* Area_Caracteristicas_Generales_Personas
* ------------------------------------------------------------------------------
* A| Se importa las bases de datos. Puede hacerse vía:
*	 (En la pantalla principal) Archivo -> Importar -> Datos de texto (delimitados, *.csv, ...)
import delimited Area_Caracteristicas_Generales_Personas.csv, delimiters(";") clear	// El archivo se encuentra delimitado por ";", y no importa
																					// si previamente se encuentra cargada una base de datos.
* B| Se edita los nombres de las variables. Puede hacerse vía:
*	 (En la pantalla principal) Propiedades de las variables. 
rename ïdirectorio directorio														// Por alguna razón, la base de datos importa mal el primer nombre.
label variable directorio "DIRECTORIO"												// Corregimos, también, su etiqueta.
* C| Se crea las variables que conformarán la llave del merge. Puede hacerse vía:
* 	 Datos -> Crear o cambiar datos -> Crear variable nueva.
gen str3 id_per = string(orden, "%03.0f")			// Se recomienda ver la documentación de Stata.
gen str3 id_hog = string(secuencia_p, "%03.0f")
tostring directorio, generate(id_viv)
* drop(id_viv)										// Por si quisiéramos eliminar alguna variable.
gen id = id_viv + id_hog + id_per					// Llave final.
* D| Exportamos la base de datos a formato. Puede hacerse vía:
*	 (En la pantalla principal) Datos -> Editor de datos -> Editor de datos (Editar/Explorar) (Da igual qué se seleccione).
*	 (En el editor de datos)    Archivo -> Guardar como (Se elige un nombre y se exporta).
save "Area_Caracteristicas_Generales_Personas.dta"

* Area_Ocupados
* ------------------------------------------------------------------------------
* Análogamente...
import delimited Area_Ocupados.csv, delimiters(";") clear
rename ïdirectorio directorio
label variable directorio "DIRECTORIO"
gen str3 id_per = string(orden, "%03.0f")
gen str3 id_hog = string(secuencia_p, "%03.0f")
tostring directorio, generate(id_viv)
gen id = id_viv + id_hog + id_per
save "Area_Ocupados.dta"

* ------------------------------------------------------------------------------
* Segunda parte
* ------------------------------------------------------------------------------
* A| Se importa el .dta
use "Area_Ocupados.dta", clear

* C| Se realiza la unión. Puede hacerse vía:
*	 Datos -> Combinar conjuntos de datos -> Fusionar dos conjuntos de datos.
sort id
merge m:1 id using Area_Caracteristicas_Generales_Personas.dta, nogenerate	// Se recomienda ver la documentación de Stata.

* ------------------------------------------------------------------------------
* Tercera parte
* ------------------------------------------------------------------------------
save "Base_Final.dta"
use "Base_Final.dta", clear

/* Las variables son:
	- Horas de trabajo a la semana: p6800; p850; p7045 (Segundo trabajo).
	- Ingresos laborales: inglabo.
	- Edad: p6040
	- Escolaridad: esc
	- Sexo: p6020
   Además, nótese que en el Visor de Datos, los colores informan acerca del tipo
   de variable al cual nos estamos enfrentando, tal que:
    - Azul: Categórica.
	- Rojo: Alfanumérica.
	- Negro: Numérica.
   Lo anterior puede corroborarse a través de 'describe variable', en la consola.
*/

destring inglabo, replace			// La variable fue leída como un string y debe corregirse. Puede hacerse vía:
									// Datos -> Crear o cambiar datos -> Otros comandos para transformar variables -> Convertir variables de tipo alfanumérico a numérico.
									// Nota: Puede tanto reemplazarse sobre la variable original como crear una nueva y comparar. Para esto último, nótese:
									//		 list inglabo inglabo_ in 1/10, lo cual generará una tabla, aparentemente, idéntica, pero con la diferencia deseada.
									//		 describe inglabo inglabo_, de forma tal que ya podemos obtener estadística descriptiva, summarize inglabo_
gen wh = (inglabo*12)/(p6800*52) 	// Salario.
gen lwh = log(wh) if inglabo>1000	// Logaritmo del salario, dada una cota inferior.
destring esc, replace		
gen x = p6040 - esc - 5				// Experiencia potencial.
gen x2 = x^2					  	// Experiencia potencial al cuadrado.
gen dsex = 1 if p6020 == 1			// Variable del sexo.
replace dsex = 0 if dsex == .		// Complemento de los valores missing de la variable anterior.
tabulate dsex						// Puede verse información acerca de la distribución de los sexos en 'tabulate dsex'.
									// Para editar el valor de las etiquetas, véase:
									// Datos -> Manejador de variables -> Etiqueta de valor -> Administrar
									// Acá se dará un nombre al conjunto de etiquetas. En este caso, 'Sexo', y posteriormente se asignará el valor y la etiqueta correspondiente.
									// Al guardar, solo deberá seleccionarse en el Manejador de variables, y estará todo listo. Revisar los datos con 'tabulate dsex'.
label define Sexo 0 "Mujer" 1 "Hombre"
label variable dsex "Sexo"
label values dsex Sexo

* ------------------------------------------------------------------------------
* Cuarta parte:
* ------------------------------------------------------------------------------
regress lwh esc x x2
	predict lwh_hat if lwh!=.
		sort lwh_hat
		gen n = _n
			scatter lwh lwh_hat n if lwh!=.
			scatter lwh lwh_hat esc if lwh!=.
			scatter lwh lwh_hat x if lwh != .
sum n if lwh != .

regress lwh esc x x2 dsex

