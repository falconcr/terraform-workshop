### Estructura del Proyecto

Una estructura típica para un proyecto de Ansible que usa roles podría verse así:

```bash
ansible-nginx/
├── ansible.cfg
├── inventories/
│   ├── production/
│   │   └── hosts
│   └── staging/
│       └── hosts
├── playbooks/
│   └── install_nginx.yml
├── roles/
│   └── nginx/
│       ├── defaults/
│       │   └── main.yml
│       ├── tasks/
│       │   └── main.yml
│       └── templates/
│           └── nginx.conf.j2
└── vars/
    └── main.yml
```

### 1. Archivo de Configuración: `ansible.cfg`

Este archivo le dice a Ansible dónde buscar los inventarios y cómo comportarse. Aquí un ejemplo básico:

```ini
[defaults]
inventory = inventories
roles_path = roles
host_key_checking = False
```

### 2. Inventarios

Los inventarios definen los servidores o nodos en los que Ansible va a ejecutar las tareas. Tendremos inventarios para diferentes entornos (por ejemplo, **development** y **staging**).

#### Inventario de **development**: `inventories/staging/hosts`

```ini
[ubuntu]
ubuntu-server ansible_host=192.168.1.10 ansible_user=ubuntu

[debian]
debian-server ansible_host=192.168.1.11 ansible_user=debian

[arch]
arch-server ansible_host=192.168.1.12 ansible_user=arch
```

#### Inventario de **staging**: `inventories/production/hosts`

Similar al de **development**, pero con servidores diferentes.

### 3. Playbook Principal: `playbooks/install_nginx.yml`

El **playbook** define las tareas que se van a ejecutar. Aquí indicamos que vamos a usar el rol `nginx` para instalar el servidor web.

```yaml
---
- name: Install NGINX on Unix systems
  hosts: all
  become: true
  vars_files:
    - ../../vars/main.yml

  roles:
    - nginx
```

### 4. Roles

El rol `nginx` se encargará de instalar NGINX en diferentes distribuciones de Linux. Se pueden usar variables para manejar las diferencias entre los sistemas operativos.

#### Variables: `roles/nginx/defaults/main.yml`

Aquí definimos las variables predeterminadas, como los comandos para instalar NGINX en cada distribución.

```yaml
nginx_package_name: "nginx"

# Comandos de instalación específicos para cada distribución
nginx_install_command:
  ubuntu: "apt-get install -y {{ nginx_package_name }}"
  debian: "apt-get install -y {{ nginx_package_name }}"
  arch: "pacman -S --noconfirm {{ nginx_package_name }}"

nginx_service_name: "nginx"
```

#### Tareas: `roles/nginx/tasks/main.yml`

El archivo de tareas ejecutará los comandos específicos según el sistema operativo detectado.

```yaml
---
- name: Install NGINX on Ubuntu, Debian, Arch
  ansible.builtin.package:
    name: "{{ nginx_package_name }}"
    state: present
  when: ansible_distribution in ['Ubuntu', 'Debian', 'Arch']

- name: Start and enable NGINX service
  ansible.builtin.service:
    name: "{{ nginx_service_name }}"
    state: started
    enabled: true
```

#### Template para el archivo de configuración de NGINX: `roles/nginx/templates/nginx.conf.j2`

Un ejemplo simple de un archivo de configuración de NGINX que se puede personalizar según las necesidades.

```nginx
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
}
```

### 5. Variables Globales: `vars/main.yml`

Aquí podemos definir variables globales que afectarán a todas las máquinas. Podemos definir las versiones de NGINX, configuraciones específicas, o cualquier otra variable que queramos reutilizar en varias partes del proyecto.

```yaml
nginx_version: "1.18.0"
```

### Cómo Ejecutar el Proyecto

Para ejecutar este proyecto, simplemente puedes usar el siguiente comando para los servidores en **staging**:

```bash
ansible-playbook playbooks/install_nginx.yml -i inventories/staging/hosts
```

O si quieres ejecutarlo en producción:

```bash
ansible-playbook playbooks/install_nginx.yml -i inventories/production/hosts
```

### Explicación del Proyecto

1. **Inventarios**: Definen los servidores en los que se ejecutará Ansible, separados por entorno.
2. **Playbooks**: Definen la secuencia de roles o tareas que se ejecutarán en los servidores.
3. **Roles**: Agrupan tareas relacionadas (como la instalación de NGINX) y hacen uso de variables y plantillas para manejar diferentes distribuciones de Linux.
4. **Variables**: Son fundamentales para que el proyecto sea flexible y adaptable a múltiples sistemas operativos.
5. **Tareas**: Ejecutan comandos específicos para instalar, configurar y habilitar NGINX en cada distribución.


### ¿Qué es `nginx_install_command`?
`nginx_install_command` es una variable que contiene los comandos específicos de instalación para cada distribución de Linux. El objetivo es que puedas ejecutar los comandos apropiados según el sistema operativo en el que Ansible esté trabajando, lo cual es necesario porque diferentes distribuciones utilizan diferentes gestores de paquetes:

- **Ubuntu/Debian**: usan `apt-get`.
- **Arch**: usa `pacman`.

### Actualización de las Tareas para Usar `nginx_install_command`

Voy a modificar las tareas para que usen esta variable. Aquí es donde la llamaremos en el archivo **`tasks/main.yml`** del rol `nginx`. De esta manera, Ansible ejecutará el comando correcto según la distribución.

```yaml
---
- name: Install NGINX on Ubuntu, Debian, Arch
  ansible.builtin.command: "{{ nginx_install_command[ansible_distribution | lower] }}"
  when: ansible_distribution in ['Ubuntu', 'Debian', 'Arch']

- name: Start and enable NGINX service
  ansible.builtin.service:
    name: "{{ nginx_service_name }}"
    state: started
    enabled: true
```

### Desglose

1. **ansible.builtin.command**: Este módulo ejecuta un comando directamente en el sistema, y aquí estamos utilizando la variable `nginx_install_command`.
   
   - **`nginx_install_command[ansible_distribution | lower]`**: Lo que hace es buscar el comando de instalación adecuado según la distribución del sistema operativo. El `ansible_distribution` devuelve el nombre de la distribución (por ejemplo, `Ubuntu` o `Arch`), y el filtro `| lower` lo convierte a minúsculas, para que coincida con las claves definidas en la variable `nginx_install_command` (que están en minúsculas: `ubuntu`, `debian`, `arch`).

   Así, Ansible seleccionará el comando apropiado:
   - Para **Ubuntu** o **Debian**: Ejecutará `apt-get install -y nginx`.
   - Para **Arch**: Ejecutará `pacman -S --noconfirm nginx`.

2. **when**: Esta condición asegura que la tarea solo se ejecute en distribuciones compatibles (Ubuntu, Debian o Arch).

3. **ansible.builtin.service**: Después de instalar NGINX, se asegura de que el servicio esté **iniciado** y **habilitado** para que arranque automáticamente con el sistema.

### Actualización de las Variables en `defaults/main.yml`

Este archivo **ya estaba bien**, pero te lo recuerdo para que lo tengas claro. Define los comandos de instalación para cada distribución:

```yaml
nginx_package_name: "nginx"

nginx_install_command:
  ubuntu: "apt-get install -y {{ nginx_package_name }}"
  debian: "apt-get install -y {{ nginx_package_name }}"
  arch: "pacman -S --noconfirm {{ nginx_package_name }}"

nginx_service_name: "nginx"
```

Aquí es donde hemos definido:
- **nginx_package_name**: Nombre del paquete de NGINX.
- **nginx_install_command**: Contiene los comandos de instalación para cada distribución de Linux.
- **nginx_service_name**: Nombre del servicio NGINX para que se pueda iniciar y habilitar correctamente.

### Ejecución Final

Al ejecutar el playbook, Ansible seleccionará el comando de instalación adecuado dependiendo de la distribución del servidor en el que esté trabajando. Por ejemplo:

- Si es **Ubuntu**, ejecutará: `apt-get install -y nginx`.
- Si es **Arch**, ejecutará: `pacman -S --noconfirm nginx`.

### Resumen


1. **Variables en `defaults/main.yml`**: Definimos los comandos de instalación específicos para Ubuntu, Debian y Arch.
2. **Tareas en `tasks/main.yml`**: Modificamos las tareas para ejecutar el comando correcto usando la variable `nginx_install_command`.
3. **Lógica Condicional**: Ansible selecciona el comando según el sistema operativo del servidor usando `ansible_distribution`.

Esto hace que el rol sea **flexible y reutilizable** para varias distribuciones de Linux. ¡Ideal para enseñar a tus estudiantes cómo manejar múltiples sistemas con una sola estructura de código!


### Usando la Plantilla en Ansible

Las plantillas en Ansible se utilizan con el módulo `ansible.builtin.template`, que permite copiar un archivo desde el directorio de plantillas de Ansible al servidor de destino, reemplazando las variables que hay dentro de la plantilla.

En este caso, la plantilla `nginx.conf.j2` es una configuración genérica para NGINX que se adapta dependiendo de las variables definidas en tu proyecto.

### ¿Dónde se usa la plantilla?

La plantilla debe ser usada en el archivo **tasks/main.yml** del rol `nginx`, justo después de que NGINX haya sido instalado, ya que necesitamos configurar el servicio antes de iniciarlo.

Actualicemos las tareas para desplegar la plantilla:

#### `tasks/main.yml` - Actualización

```yaml
---
- name: Install NGINX on Ubuntu, Debian, Arch
  ansible.builtin.command: "{{ nginx_install_command[ansible_distribution | lower] }}"
  when: ansible_distribution in ['Ubuntu', 'Debian', 'Arch']

- name: Deploy NGINX configuration template
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'

- name: Start and enable NGINX service
  ansible.builtin.service:
    name: "{{ nginx_service_name }}"
    state: started
    enabled: true
```

### Desglose

1. **ansible.builtin.template**: Este módulo copia el archivo de la plantilla `nginx.conf.j2` desde el directorio `templates/` del proyecto de Ansible hacia el servidor de destino, reemplazando cualquier variable dentro del archivo de plantilla con los valores que hayamos definido en las variables de Ansible.

   - **src**: Especifica el archivo fuente, es decir, la plantilla en el directorio `templates/`.
   - **dest**: El destino en el servidor de destino donde queremos copiar el archivo (en este caso, `/etc/nginx/nginx.conf`).
   - **owner** y **group**: Definen el propietario y grupo del archivo en el servidor (aquí usamos `root`).
   - **mode**: Define los permisos del archivo en formato octal (aquí `0644`).

### Variables en la Plantilla `nginx.conf.j2`

Ahora, vamos a usar la plantilla que está en el directorio **`templates/nginx.conf.j2`**. Un ejemplo de contenido para esta plantilla podría ser el siguiente:

#### `templates/nginx.conf.j2`

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    server {
        listen 80;
        server_name {{ nginx_server_name }};
        
        location / {
            root {{ nginx_document_root }};
            index index.html;
        }
    }
}
```

### Desglose de la Plantilla

- **`{{ nginx_server_name }}`**: Esta variable se reemplaza con el nombre del servidor (puedes definirla en `defaults/main.yml` o pasarla como variable en el playbook).
- **`{{ nginx_document_root }}`**: Esta variable define el directorio raíz de los archivos del servidor web, y también puede definirse en las variables.

### Actualización del Archivo de Variables (`defaults/main.yml`)

Debemos asegurarnos de que las variables usadas en la plantilla estén definidas. Por ejemplo:

#### `defaults/main.yml` - Actualización

```yaml
nginx_package_name: "nginx"

nginx_install_command:
  ubuntu: "apt-get install -y {{ nginx_package_name }}"
  debian: "apt-get install -y {{ nginx_package_name }}"
  arch: "pacman -S --noconfirm {{ nginx_package_name }}"

nginx_service_name: "nginx"

# Variables for the NGINX configuration
nginx_server_name: "localhost"
nginx_document_root: "/var/www/html"
```

### Ejecución Completa del Flujo

1. **Instalación de NGINX**: La primera tarea instala NGINX en la máquina, dependiendo de la distribución de Linux.
2. **Despliegue de la Configuración**: Luego, la tarea que usa `ansible.builtin.template` copia el archivo `nginx.conf` generado por la plantilla hacia el servidor, reemplazando las variables (`nginx_server_name`, `nginx_document_root`, etc.) con los valores definidos en `defaults/main.yml`.
3. **Iniciar y Habilitar NGINX**: Finalmente, se asegura que el servicio de NGINX esté iniciado y habilitado para arrancar automáticamente al iniciar el servidor.

### Resumen

Ahora hemos incorporado la plantilla correctamente dentro de las tareas de Ansible. La plantilla `nginx.conf.j2` será aplicada para generar la configuración de NGINX de manera dinámica, según las variables definidas en el proyecto.

Este enfoque muestra a tus estudiantes cómo un proyecto Ansible bien estructurado puede gestionar tanto la instalación de software como la configuración mediante plantillas, adaptándose a diferentes entornos de forma flexible.

### Conclusión

Este proyecto enseña a los estudiantes cómo estructurar correctamente un proyecto de Ansible con **roles**, **playbooks**, **inventories** y **variables**, lo que facilita la instalación de software en diferentes sistemas operativos de forma flexible y mantenible.