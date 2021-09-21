# recorridoApp

Aplicación de prueba usando la API pública de [recorrido.cl](http://recorrido.cl/).

La aplicación permite la creación de alertas de precios, con los cuales se pueden buscar ofertas de pasajes de bus,
y se buscan los pasajes más baratos considerando ciudad de partida y destino, y clase de bus, disponibles en los próximos 7 días. Una vez creada y vista una alerta, la plataforma busca nuevas ofertas de pasajes cada 5 minutos. Además, guarda un historial de los precios más bajos encontrados.

La aplicación usa Ruby (v 3.0.2) on Rails (v 6.1.4) y Vue.js(2.6), ambos ejecutado en localhost el mismo puerto. Además, usa PostgreSQL 12.8 como base de datos.

## Instalación (Ubuntu 20.04)

Después de clonar el repositorio, se debe asegurar que exista un usuario de postgres con permisos de creación y edición sobre la base de datos que esté con las mismas credenciales que en config/database.yml. [Link que puede ser de ayuda](https://stackoverflow.com/a/10565632)
Se debe instalar yarn, webpacker en caso de ser necesario.

## Ejecución

Correr en terminal:
`rails s`
Ir a localhost:3000.
Hacer click en nueva alerta, crear alerta.
Para cargar la alerta y las llamadas a la API, hacer click en el ojo de la alerta.
Se debiera cargar un ActiveJob por detrás que actualiza los precios y los pasajes cada 5 minutos. Estos también se reactivan cuando se carga Rails con `rails s`.
Cuando se edita una alerta, se puede tener que esperar a la nueva actualización para ver los datos nuevos. Tener ojo que pueden haber problemas de concurrencia si se edita mientras se está corriendo el ActiveJob (problema no resuelto).

## Diseño

Diagrama de Clases:
![alt text](https://github.com/selira/recorridoapp/blob/master/app/assets/UML.jpg?raw=true)



Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
