# Mapa de Ingresos Reales y Lineas de Pobreza en México

Mapa interactivo de lineas y puntos de los Ingresos Reales y Lineas de Pobreza en México realizados en Shiny App. 
```
library(shiny)
```
![image](https://user-images.githubusercontent.com/85140481/194924751-98efddf2-3adf-42a7-bc57-bcd79d1122cc.png)

* Para consultar la [App en Shiny](https://fernando-per-es-99.shinyapps.io/IngresoRealMex/) y ver el resultado final.
## Filtros
Incluye Filtros de Años, Trimestres, Entidad Federativa y Tipos de Linea de Pobreza, estos filtros están hechos con 
```
library(shinyWidgets)
```
Y graficados mediante
```
library(plotly)
```
![image](https://user-images.githubusercontent.com/85140481/194925401-76467e14-6087-4d2d-9cc6-232986917bbf.png)

## Pestañas
La página cuenta con 3 pestañas, la gráfica que es interactiva, la base de datos que igualmente es interactiva y que incluye un filtro interno, y un ReadMe que incluye información pertinente de los datos

![image](https://user-images.githubusercontent.com/85140481/194925787-5490a65a-6eea-48fd-9a64-daa89440681d.png)

### NOTA:
Para una correcta visualización, es necesario verlo en un dispositivo como Laptop / Monitor. Ya que desde el celular no se aprecia correctamente la gráfica
