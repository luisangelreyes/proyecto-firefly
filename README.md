Un juego de Coyote Studio: #  Recolectores: Reordenando Resiudos

> *"Lo que tiramos no desaparece — alguien lo carga."*

<div align="center">

![Godot Engine](https://img.shields.io/badge/Godot-4.x-478CBF?style=for-the-badge&logo=godot-engine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-Language-478CBF?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Offline](https://img.shields.io/badge/Modo-100%25%20Offline-2ECC71?style=for-the-badge)
![SEP](https://img.shields.io/badge/Alineado-SEP%20México-C0392B?style=for-the-badge)

**Un juego serio educativo sobre clasificación de residuos sólidos urbanos, desarrollado para escuelas primarias.**

</div>

---

## 📖 ¿Qué es Recolectores?

**Recolectores: Reordenando Residuos** es un videojuego educativo 2D desarrollado por **Coyote Studio** como proyecto de juego serio (*serious game*) orientado a estudiantes de educación primaria (6–12 años).

El juego sigue a **Liz** y su abuelo **Sergio**, pepenadores urbanos que trabajan clasificando los residuos que la gente abandona en las calles. A través de sus ojos, el jugador aprende a identificar, clasificar y comprender el impacto ambiental de los residuos sólidos urbanos.

---



## 🧠 Fundamento Pedagógico

El juego está diseñado siguiendo la **tabla de Mecánicas de Aprendizaje – Mecánicas de Juego (LM-GM)** y alineado con objetivos curriculares de la **SEP (Secretaría de Educación Pública)** de México.

| LM | Mecánica de juego | Nivel Bloom | Tipo de contenido |
|---|---|---|---|
| LM-1 | Atrapar residuos con el bote correcto | Recordar | Conceptual |
| LM-2 | Arrastrar objetos a costales por material | Comprender | Conceptual + Procedimental |
| LM-3 | Identificar y esquivar residuos peligrosos | Aplicar | Procedimental + Actitudinal |
| LM-4 | Pantalla de Game Over con consejo ambiental | Evaluar | Actitudinal |

El error no es penalización — es **retroalimentación formativa**. Cada clasificación incorrecta activa una explicación breve de Don Sergio sobre por qué ese residuo pertenece a otra categoría.

---

## 🕹️ Mecánicas Principales

### Nivel 1 — Caída de Residuos
Inspirado en los clásicos arcade de caída de objetos. Los residuos caen desde la parte superior de la pantalla y Liz debe atraparlos con el bote correcto (orgánico/inorgánico) o esquivarlos si son peligrosos. El nivel funciona por **oleadas definidas** — no es infinito — y al terminar muestra una pantalla de resultados con cuántos residuos clasificaste, cuántos se escaparon y tu puntaje.

### Nivel 2 — Clasificación del Morral
Los residuos recolectados durante la jornada salen uno por uno del morral de Liz. El jugador tiene **8 segundos** para arrastrar cada objeto al contenedor correcto (papel, vidrio, plástico). Si el tiempo se agota, pierde una vida pero puede intentarlo de nuevo con el mismo objeto. Los errores muestran una explicación educativa antes de continuar.

### Nivel 3 — Exploración Top-Down *(en desarrollo)*
Vista cenital estilo *Hotline Miami* adaptada al contexto educativo. Liz recorre un terreno baldío recolectando residuos dispersos. El **vagabundo** y su **perro** patrullan el territorio — si te detectan, el nivel reinicia completamente. Una sola vida. La dificultad viene de leer patrones, no de velocidad de reacción.

---

## 👥 Personajes

### Eli
Protagonista principal. Joven pepenadora que aprende el oficio de su abuelo. Enérgica, curiosa y comprometida con su comunidad. Sus animaciones de caminar e idle reflejan el contexto urbano popular mexicano.

### Don Sergio
El abuelo de Eli. Pepenador experimentado que conoce el sistema de reciclaje desde adentro. Aparece como narrador y consejero — sus líneas de diálogo son el canal principal de retroalimentación educativa.

### El Vagabundo y su perro
Antagonistas no violentos del Nivel 3. También dependen de los residuos para sobrevivir, pero de forma diferente a Eli y Don Sergio. No son villanos — son un espejo del mismo sistema visto desde otro ángulo. El perro patrulla de forma independiente con IA de persecución.

---

## 🏫 Diseño para el Aula

Recolectores fue diseñado con restricciones reales del sistema escolar mexicano:

- **Sin instalación** — corre como `.exe` standalone en Windows, sin permisos de administrador
- **Sin internet** — 100% offline, sin dependencias externas
- **Perfiles múltiples** — hasta N estudiantes en el mismo equipo, cada uno con progreso aislado

### Accesibilidad
- Tamaño de texto ajustable (normal / grande / muy grande)
- Filtros de corrección de color (deuteranopía, protanopía, tritanopía)
- Reducción de efectos visuales de movimiento
- Velocidad global del juego: 75% / 100% / 125%

---

## ⚙️ Especificaciones Técnicas

```
Motor:           Godot Engine 4.x
Lenguaje:        GDScript
Resolución base: 1920×1080 (arquitectura pillarboxing 1440×1080 interior)
Plataforma:      Windows (ejecutable .exe standalone)
Control:         Teclado, mouse 
Audio:           Música Del Gran Tee Lopez y Kenneth C M Young + SFX del compositor Kenta Nagata
Visuales tomados y basados en el arte de JULIAN NGUYEN-YOU
Guardado:        JSON local en user:// (sin nube, sin registro)
```

---


---

## 🚀 Cómo ejecutar el proyecto

### En Godot Engine (desarrollo)
```bash
1. Clonar el repositorio
2. Abrir Godot Engine 4.x
3. Importar el proyecto desde la carpeta raíz
4. Ejecutar con F5 o el botón ▶
```

### Como ejecutable (distribución)
```
1. Descargar el .exe desde Releases
2. Ejecutar directamente — no requiere instalación
3. El archivo de guardado se crea automáticamente en:
   Windows: %APPDATA%/Godot/app_userdata/Recolectores/
```

---

## 👨‍💻 Equipo

**Coyote Studio**

| Nombre | Rol |
|---|---|
| Luis Ángel Reyes Mendoza | dirección, programación, diseño, Sonido|
| Fabián Hernández José Manuel | Programación |
| José Mateos De La Cruz |  Programación , feedback educativo |
| César Eloy Trujillo Martínez | Sistemas de datos, analytics, Programación Opciones Accesibles |
---


## 📄 Licencia

Este proyecto es desarrollado con fines **académicos y educativos no comerciales**.  
Es posible que elementos del juego estén sujetas a derechos de autor. 
El código fuente está disponible para fines de investigación en diseño de juegos serios.

---

<div align="center">

**Coyote Studio © 2025**

</div>
