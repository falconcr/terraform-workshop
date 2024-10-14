Ansible es una herramienta de automatización de código abierto que permite administrar sistemas y configurar infraestructuras de forma sencilla. A través de "playbooks" (archivos YAML que definen las tareas), Ansible puede configurar servidores, instalar software, administrar configuraciones y más, todo sin necesidad de instalar agentes en los nodos gestionados.

## Conceptos básicos de Ansible

- Control Node: Es el equipo desde donde ejecutas Ansible. Puede ser tu máquina local o una instancia EC2.

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
sudo apt install ansible -y
pip install --upgrade ansible
```

Accede a tus EC2: Configura las credenciales SSH y asegúrate de que puedas acceder a las instancias EC2 desde el nodo de control.