Ansible es una herramienta de automatización de código abierto que permite administrar sistemas y configurar infraestructuras de forma sencilla. A través de "playbooks" (archivos YAML que definen las tareas), Ansible puede configurar servidores, instalar software, administrar configuraciones y más, todo sin necesidad de instalar agentes en los nodos gestionados.


## Conceptos básicos de Ansible

- Control Node: Es el equipo desde donde ejecutas Ansible. Puede ser tu máquina local o una instancia EC2. Actualmente, Ansible se puede ejecutar desde cualquier máquina que tenga instalado Python 2 (versión 2.7) o Python 3 (versiones 3.5 y superiores). Esto incluye Red Hat, Debian, CentOS, macOS, cualquiera de los BSD, etc. Windows no es compatible con el nodo de control. Al elegir un nodo de control, tenga en cuenta que cualquier sistema de gestión se beneficia de ejecutarse cerca de las máquinas que se administran. Si está ejecutando Ansible en una nube, considere ejecutarlo desde una máquina dentro de esa nube. En la mayoría de los casos, esto funcionará mejor que en Internet abierta.

- Managed Nodes: Son los sistemas que Ansible administra (en tu caso, dos instancias EC2).
Inventory: Archivo que contiene la lista de hosts o IPs que Ansible gestionará.

- Modules: Son las unidades que realizan tareas (por ejemplo, instalar paquetes, copiar archivos).

- Playbooks: Archivos YAML que describen una serie de tareas que Ansible ejecutará en los nodos.

- Idempotencia: Ansible garantiza que si ejecutas una tarea varias veces, solo se aplicará si hay cambios necesarios, evitando modificaciones innecesarias.

## Instalación de Ansible (en el nodo de control)

Primero, asegúrate de tener acceso SSH a las instancias EC2 y de que Ansible esté instalado en el nodo de control (tu máquina local o una EC2).

### Instala Ansible en el nodo de control (Ubuntu/Debian):

```
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

Accede a tus EC2: Configura las credenciales SSH y asegúrate de que puedas acceder a las instancias EC2 desde el nodo de control.

Para estructurar un proyecto de Ansible según las buenas prácticas, es importante seguir un conjunto de convenciones que ayuden a mantener el código organizado, modular y reutilizable. Estas convenciones son especialmente útiles en proyectos grandes o de larga duración. Aquí te dejo una estructura comúnmente recomendada, conocida como **Best Practice Layout**, que Ansible sugiere para proyectos más robustos:

### Estructura básica recomendada

```bash
ansible_project/
├── ansible.cfg
├── inventories/
│   ├── production/
│   │   ├── hosts
│   │   └── group_vars/
│   │       └── all.yml
│   └── staging/
│       ├── hosts
│       └── group_vars/
│           └── all.yml
├── playbooks/
│   ├── site.yml
│   └── webservers.yml
├── roles/
│   └── common/
│       ├── tasks/
│       │   └── main.yml
│       ├── handlers/
│       │   └── main.yml
│       ├── templates/
│       ├── files/
│       ├── vars/
│       │   └── main.yml
│       ├── defaults/
│       │   └── main.yml
│       ├── meta/
│       │   └── main.yml
│       ├── tests/
│       │   ├── inventory
│       │   └── test.yml
│       └── README.md
└── group_vars/
    └── all.yml
```

### Descripción de cada elemento:

#### 1. `ansible.cfg`
Este es el archivo de configuración principal de Ansible, donde puedes definir varias opciones de comportamiento, como la ruta al inventario por defecto, conexión SSH, y más. Un ejemplo básico:

```ini
[defaults]
inventory = ./inventories/staging/hosts
remote_user = ubuntu
host_key_checking = False
retry_files_enabled = False
```

#### 2. `inventories/`
Este directorio contiene los diferentes entornos (por ejemplo, `production`, `staging`, etc.) y dentro de cada uno, los archivos de inventario que definen los hosts gestionados y las variables específicas para cada grupo.

- **`production/hosts` y `staging/hosts`**: Contienen las direcciones IP o nombres de los servidores que Ansible gestionará. Un ejemplo de archivo `hosts` podría verse así:

```ini
[webservers]
web1 ansible_host=192.168.1.1

[dbservers]
db1 ansible_host=192.168.1.2
```

- **`group_vars/`**: Aquí puedes definir variables específicas por grupo de hosts. Por ejemplo, `all.yml` aplicará las variables a todos los hosts del inventario.

#### 3. `playbooks/`
Este directorio contiene los playbooks principales. Cada playbook puede ejecutar un conjunto de tareas específicas o incluir otros playbooks. Por ejemplo:

- **`site.yml`**: Playbook maestro que puede incluir otros playbooks o tareas.
- **`webservers.yml`**: Playbook para configurar servidores web.

Ejemplo básico de un playbook:

```yaml
---
- name: Configure web servers
  hosts: webservers
  roles:
    - common
    - web
```

#### 4. `roles/`
Este directorio contiene los **roles**, que son una forma modular y reutilizable de agrupar tareas relacionadas con la configuración de servidores.

- **`common/`**: Ejemplo de un rol llamado `common` que se podría aplicar a todos los hosts.
  - **`tasks/`**: Aquí defines las tareas que se ejecutarán. El archivo `main.yml` es el punto de entrada.
  - **`handlers/`**: Contiene los manejadores que se activan cuando ciertas tareas requieren acciones adicionales, como reiniciar un servicio.
  - **`templates/`**: Plantillas de archivos configurables, normalmente en formato Jinja2 (`.j2`), como un archivo de configuración de NGINX.
  - **`files/`**: Archivos estáticos que puedes copiar a los servidores.
  - **`vars/`**: Variables específicas del rol.
  - **`defaults/`**: Valores predeterminados de las variables, que pueden ser sobrescritos en otros niveles.
  - **`meta/`**: Información sobre el rol, como dependencias de otros roles.
  - **`tests/`**: Archivos de prueba para el rol.
  - **`README.md`**: Documentación del rol.

Ejemplo del archivo `tasks/main.yml` dentro de un rol:

```yaml
---
- name: Install NGINX
  apt:
    name: nginx
    state: present
```

#### 5. `group_vars/`
Aquí se definen variables para grupos de hosts de manera global (aplican a todos los hosts, a menos que se sobrescriban).

### Buenas prácticas clave:

1. **Usa roles**: Agrupa las tareas comunes en roles reutilizables. Esto permite una mejor organización y modularidad.
2. **Separación de entornos**: Mantén separados los archivos de inventario para diferentes entornos (producción, staging, etc.) y usa variables específicas para cada entorno.
3. **Variables bien organizadas**: Usa `group_vars` y `host_vars` para gestionar variables específicas para grupos o hosts individuales, evitando variables hardcoded en los playbooks.
4. **Plantillas y archivos**: Coloca archivos estáticos en la carpeta `files/` y utiliza plantillas dinámicas con Jinja2 en la carpeta `templates/` cuando sea necesario.
5. **Documentación**: Documenta tus roles y playbooks para facilitar su comprensión y mantenimiento.
6. **Manejo de errores**: Usa handlers para reiniciar servicios cuando sea necesario y asegúrate de que las tareas sean idempotentes (que no cambien el estado del servidor si ya está configurado correctamente).

### Ejemplo de uso

1. Ejecuta un playbook para el entorno de staging:

```bash
ansible-playbook -i inventories/staging/hosts playbooks/site.yml
```

2. Para producción, simplemente cambia el inventario:

```bash
ansible-playbook -i inventories/production/hosts playbooks/site.yml
```

Esta estructura te permitirá mantener tu proyecto escalable, modular, y fácil de gestionar a medida que crezca.