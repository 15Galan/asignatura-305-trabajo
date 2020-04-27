# Trabajo en grupo

## Consideraciones
   * Reservar la rama *master* para publicar las entregas, es decir, realizar un *merge* solo con código definitivo.
   * Crear una rama para trabajar en ella antes de cada entrega con el fin de separar cada parte del trabajo.
   * Cada uno trabajará sobre este mismo repositorio pero creando su propia rama (temporal) para no interferir con el trabajo de los demás en el caso de que se trabaje en paralelo.


## Inicialización
### Descargar e instalar Git BASH
Una vez instalado, almacenar tus credenciales:
1. Abre Git BASH usando el click derecho en cualquier ubicación local.
2. Usa `git config --global user.name "<nombre>"` para establecer tu alias (no tiene por qué ser tu nombre de usuario).
3. Usa `git config --global user.email <email>` para establecer la dirección de correo de tu cuenta de GitHub y sincronizar tu usuario.

### Sincronizar el repositorio
1. Abre Git BASH (si no lo has hecho ya) en la ubicación donde quieras guardar el repositorio.
2. Usa `git clone <URL de este repositorio>`, para descargar el repositorio y tener una copia local.
3. Ahora existirá la carpeta local del repositorio en la ubicación indicada, desplázate a ella con `cd asignatura-305-trabajo` y ejecuta el resto de comandos ahí.
4. Usa `git pull` para descargar y fusionar todos los cambios si crees que tu repositorio local está desactualizado. Te recomiendo ejecutarlo siempre antes de empezar a trabajar.


## Trabajar en el respositorio
### Hacer un cambio
1. Usa `git checkout -b <nombre de mi-rama>` para crear una rama temporal y cambiarse a ella (se verá reflejado en la línea de comandos).
2. Realiza tus cambios del repositorio en esa rama.
 * Usa `git status` para revisar los cambios. Aparecerán en rojo los no registrados (modificaciones y/o archivos nuevos).
 * Usa `git add <archivos>` para registrar los cambios (archivos, carpetas...). Usa * para registrar todos los archivos modificados.

### Guardar un cambio
Usa `git commit` para confirmar y guardar los cambios localmente. Esto abrirá un editor en la consola para describir el commit (título y cuerpo). Suponiendo que el editor es Vim (lo normal):
1. Presiona *i* para escribir.
2. El título del commit se detectará en la primera línea (amarillo).
3. La segunda línea debe estar vacía (si se escribe en ella aparecerá en rojo).
4. La tercera línea y las demás se detectarán como el cuerpo del commit (gris).
5. Presiona *esc* para dejar de escribir y teclea *:wq* (que aparecerá en la parte baja del editor).
6. Presiona *enter* para salir y guardar los cambios.
  
 * Puedes usar `git commit -m "<título>"` para realizar un commit rápido con el título indicado, pero sin cuerpo (y sin usar editor).
 
### Fusionar un cambio
Esto es, fusionar tus cambios con la rama de trabajo, ya sea la de la entrega o *master* si es algo definitivo. Recuerda que debes estar en la rama a la que quieras llevar los cambios.
1. Cambia a la rama que quieras con `git checkout <rama>` para poder traer los cambios desde tu rama.
2. Ejecuta `git merge <mi-rama>` para traer los cambios de tu rama a la rama en la que estás (y no al revés, podría producir un error).
# Trabajo en grupo: Taller AUTORACLE


## Consideraciones
   * Reservar la rama *master* para publicar las entregas, es decir, realizar un *merge* solo con código definitivo.
   * Crear una rama para trabajar en ella antes de cada entrega con el fin de separar cada parte del trabajo.
   * Cada uno trabajará sobre este mismo repositorio pero creando su propia rama (temporal) para no interferir con el trabajo de los demás en el caso de que se trabaje en paralelo.


## Inicialización
### Descargar e instalar Git BASH
Una vez instalado, almacenar tus credenciales:
1. Abre Git BASH usando el click derecho en cualquier ubicación local.
2. Usa `git config --global user.name "<nombre>"` para establecer tu alias (no tiene por qué ser tu nombre de usuario).
3. Usa `git config --global user.email <email>` para establecer la dirección de correo de tu cuenta de GitHub y sincronizar tu usuario.

### Sincronizar el repositorio
1. Abre Git BASH (si no lo has hecho ya) en la ubicación donde quieras guardar el repositorio.
2. Usa `git clone <URL de este repositorio>`, para descargar el repositorio y tener una copia local.
3. Ahora existirá la carpeta local del repositorio en la ubicación indicada, desplázate a ella con `cd asignatura-305-trabajo` y ejecuta el resto de comandos ahí.
4. Usa `git pull` para descargar y fusionar todos los cambios si crees que tu repositorio local está desactualizado. Te recomiendo ejecutarlo siempre antes de empezar a trabajar.


## Trabajar en el respositorio
### Hacer un cambio
1. Usa `git checkout -b <nombre de mi-rama>` para crear una rama temporal y cambiarse a ella (se verá reflejado en la línea de comandos).
2. Realiza tus cambios del repositorio en esa rama.
 * Usa `git status` para revisar los cambios. Aparecerán en rojo los no registrados (modificaciones y/o archivos nuevos).
 * Usa `git add <archivos>` para registrar los cambios (archivos, carpetas...). Usa * para registrar todos los archivos modificados.

### Guardar un cambio
Usa `git commit` para confirmar y guardar los cambios localmente. Esto abrirá un editor en la consola para describir el commit (título y cuerpo). Suponiendo que el editor es Vim (lo normal):
1. Presiona *i* para escribir.
2. El título del commit se detectará en la primera línea (amarillo).
3. La segunda línea debe estar vacía (si se escribe en ella aparecerá en rojo).
4. La tercera línea y las demás se detectarán como el cuerpo del commit (gris).
5. Presiona *esc* para dejar de escribir y teclea *:wq* (que aparecerá en la parte baja del editor).
6. Presiona *enter* para salir y guardar los cambios.
  
 * Puedes usar `git commit -m "<título>"` para realizar un commit rápido con el título indicado, pero sin cuerpo (y sin usar editor).
 
### Fusionar un cambio
Esto es, fusionar tus cambios con la rama de trabajo, ya sea la de la entrega o *master* si es algo definitivo. Recuerda que debes estar en la rama a la que quieras llevar los cambios.
1. Cambia a la rama que quieras con `git checkout <rama>` para poder traer los cambios desde tu rama.
2. Ejecuta `git merge <mi-rama>` para traer los cambios de tu rama a la rama en la que estás (y no al revés, podría producir un error).
3. Elimina la rama que creaste con `git branch -d <mi-rama>`. No pasa nada si no se borra, pero es recomendale.

### Publicar un cambio
Es decir, subir los cambios al repositorio de GitHub. Todo lo anterior se ha hecho localmente.
1. Usa `git push` para publicar los cambios de tu repositorio local en el repositorio de GitHub.

Una vez hecho esto, el repositorio se actualiza para todos los miembros, de modo que si alguno sube un cambio desde su repositorio local desactualizado, recibirá un aviso para hacer un `git pull` antes.


## Comandos útiles
* `git log` muestra el historial de commits en la consola. Se cierra como el editor.
* `git reset <archivo>` anula el `git add` del archivo indicado.
