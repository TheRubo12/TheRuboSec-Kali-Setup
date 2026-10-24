# TheRuboSec Kali Setup — Road to CPTS

Scripts Bash para agilizar laboratorios autorizados de **Hack The Box** en Kali Linux XFCE: gestión básica de VPN OpenVPN, selección de target y dos indicadores en el panel superior.

> Proyecto educativo independiente. No afiliado a Hack The Box. Los iconos incluidos son **dibujos vectoriales propios** (mirilla y cubo genérico), no el logotipo oficial de HTB. Los perfiles `.ovpn` son privados: **no los publiques**.

## Vista previa

Los indicadores de **XFCE Genmon** muestran el estado de la VPN y el objetivo seleccionado, actualizándose automáticamente.

### Sin conexión y sin objetivo

![Panel XFCE: No target y Disconnected](assets/screenshots/disconnected.png)

El panel muestra **No target** y **Disconnected** cuando no hay objetivo configurado y `tun0` no tiene una dirección IPv4.

### VPN conectada y objetivo seleccionado

![Panel XFCE: objetivo Academy y VPN conectada](assets/screenshots/connected.png)

Ejemplo visual con `settarget 10.10.10.10 Academy` y la IP VPN `10.10.14.67`. Estas direcciones son ilustrativas y pueden cambiar entre sesiones.

> Las capturas muestran el panel real de Kali XFCE. El estado del indicador VPN depende de `tun0` y no autentica por sí mismo que el túnel pertenezca a HTB.

## Funcionalidades

| Comando | Función |
| --- | --- |
| `connecthtb labs` | Conectar perfil Labs |
| `connecthtb academy` | Conectar perfil Academy |
| `connecthtb starting` | Conectar perfil Starting Point |
| `connecthtb status` | Estado, PID e IP VPN |
| `connecthtb stop` | Desconectar VPN gestionada |
| `settarget 10.129.15.20 Lame` | Mostrar IP y nombre del objetivo |
| `settarget clear` | Quitar objetivo |

Los scripts `htb-status` y `target-status` generan etiquetas XML para **XFCE Genmon**. El target aparece en amarillo `#FFE45C`, la mirilla en rojo `#FF3333`, el cubo en verde `#9FEF00` y la IP VPN en blanco.

## Requisitos

- Kali Linux con XFCE (probado conceptualmente con XFCE 4.20 / Genmon 4.3).
- Bash, Python 3, `iproute2`, OpenVPN, `sudo` y `librsvg2-bin`.
- Archivos `.ovpn` descargados de tu propia cuenta HTB.

```bash
sudo apt update
sudo apt install -y openvpn iproute2 python3 xfce4-genmon-plugin librsvg2-bin
```

## Instalación

```bash
unzip TheRuboSec-Kali-Setup.zip
cd TheRuboSec-Kali-Setup
bash install.sh
```

El instalador copia los comandos a `~/.local/bin`, genera los PNG a 20×20 y guarda copias `.bak.FECHA` de scripts previos. **No altera automáticamente** tu panel ni tus VPN existentes.

En Kali con Zsh, si `command -v connecthtb` no devuelve nada, añade `~/.local/bin` a `PATH`:

```bash
printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> ~/.zshrc
source ~/.zshrc
```

### Configurar los perfiles

```bash
mkdir -p ~/.config/htb-vpn
chmod 700 ~/.config/htb-vpn
```

Copia manualmente los `.ovpn` descargados desde HTB con estos nombres (según los perfiles que realmente tengas):

```text
~/.config/htb-vpn/labs.ovpn
~/.config/htb-vpn/academy.ovpn
~/.config/htb-vpn/starting.ovpn
```

Ejemplo (sustituye `ARCHIVO_DESCARGADO.ovpn` por la ruta real):

```bash
cp ~/Downloads/ARCHIVO_DESCARGADO.ovpn ~/.config/htb-vpn/labs.ovpn
chmod 600 ~/.config/htb-vpn/*.ovpn
```

**Academy, Labs y Starting Point pueden requerir perfiles diferentes.** No renombres un perfil de Starting Point como Labs esperando acceso a todas las redes. Si no tienes `academy.ovpn`, `connecthtb academy` indicará que falta.

## Uso y comprobación

```bash
bash -n ~/.local/bin/connecthtb
bash -n ~/.local/bin/settarget
connecthtb labs
connecthtb status
ip -br -4 addr show tun0
settarget 10.129.15.20 Lame
~/.local/bin/target-status
~/.local/bin/htb-status
settarget clear
connecthtb stop
```

La IP `10.129.15.20` es **solo un ejemplo**, no una dirección fija de Lame.

### Integración en panel XFCE

1. Clic derecho en el panel superior → **Panel → Añadir nuevos elementos**.
2. Añade **dos Generic Monitor** (Genmon).
3. En las propiedades del primero configura **Comando** `/home/kali/.local/bin/target-status`.
4. En el segundo, **Comando** `/home/kali/.local/bin/htb-status`.
5. Establece intervalo **2 segundos**, oculta las etiquetas opcionales y ordénalos en el panel. Cambia `/home/kali` por tu carpeta de usuario si es distinta.

El panel ejecuta estos scripts sin `sudo`. No requiere reiniciar Kali.

## Arquitectura

```text
bin/
  connecthtb        # Inicia/detiene OpenVPN y lee PID/estado
  settarget         # Guarda target validado
  target-status     # Genmon: target
  htb-status        # Genmon: IP tun0
assets/icons/
  target.svg        # Mirilla roja original
  htb-cube.svg      # Cubo genérico verde original
assets/screenshots/
  disconnected.png  # Panel sin conexión ni target
  connected.png     # Panel con VPN y target
install.sh          # Instalación y PNG
```

Estado local (no versionar):

```text
~/.config/htb-vpn/*.ovpn
~/.config/therubosec/target
~/.local/state/connecthtb/openvpn.pid
~/.local/state/connecthtb/openvpn.log
~/.local/state/connecthtb/profile
```

## Limitaciones y seguridad

- **Solo una VPN gestionada a la vez.** Se reserva `tun0`. Si `tun0` ya existe y no está gestionada, `connecthtb` se niega a iniciar otra conexión para no interferir con otras VPN.
- El indicador `htb-status` muestra la IP de **cualquier interfaz `tun0`**; por sí solo no prueba que la conexión sea de HTB. Verifica con `connecthtb status`.
- `connecthtb` comprueba que el proceso coincide con su PID y ruta de configuración antes de enviar SIGTERM. No controla procesos OpenVPN externos.
- Si se corta la VPN inesperadamente, revisa `~/.local/state/connecthtb/openvpn.log` y `sudo pgrep -a openvpn`. Puede quedar estado obsoleto; evita borrar PID o matar procesos sin comprobarlos.
- Los perfiles `.ovpn` pueden contener secretos. No publiques certificados, claves, logs sensibles ni capturas con tokens.
- `settarget` **no modifica** `/etc/hosts` ni exporta una variable de shell. Solo actualiza el archivo de estado y el panel.
- Los warnings de compresión en perfiles OpenVPN antiguos proceden de la configuración suministrada; consulta la documentación oficial de HTB antes de cambiar opciones VPN.

## Subir a GitHub

Desde el directorio del proyecto:

```bash
git init
git add README.md .gitignore install.sh bin assets
# Revisar antes de publicar:
git status
git diff --cached --stat
git commit -m "Initial TheRuboSec Kali HTB setup"
```

Crea un repositorio vacío `TheRuboSec-Kali-Setup` en GitHub y sigue las instrucciones que te muestre GitHub para asociar el remoto y hacer `push`. **Nunca añadas tus archivos `.ovpn`**.

## Licencia

MIT. Consulta `LICENSE`.
