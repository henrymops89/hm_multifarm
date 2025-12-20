# 🐄 HM HOLY COW v0.1.0

**Farm Management System - Foundation Build**

---

## 🎯 Was ist v0.1.0?

Dies ist die **FOUNDATION** - das Fundament für ein komplettes Farm-Management-System!

**Was funktioniert:**
- ✅ Kühe kaufen (2 Rassen: Holstein & Jersey)
- ✅ Slot-System (6 Positionen)
- ✅ Kühe spawnen automatisch
- ✅ MySQL-Datenbank (persistent)
- ✅ Multi-Framework (QBox, QBCore, ESX)
- ✅ Moderner Shop mit UI

**Was NOCH NICHT funktioniert:**
- ❌ Melken (kommt in v0.4.0)
- ❌ Füttern/Pflegen (kommt in v0.2.0)
- ❌ Wachstum/Stages (kommt in v0.3.0)
- ❌ Stats-System (kommt in v0.2.0)

---

## 📦 Installation

### **1. SQL ausführen**

```sql
-- Führe aus: sql/v0.1.0_install.sql
```

### **2. Dependencies**

Benötigt:
- ox_lib
- ox_target
- oxmysql

### **3. Resource starten**

```cfg
# server.cfg
ensure oxmysql
ensure ox_lib
ensure ox_target
ensure hm_holycow
```

### **4. Koordinaten anpassen!**

⚠️ **WICHTIG:** Die SQL enthält Beispiel-Koordinaten für Grapeseed!

**Option A: SQL direkt anpassen**
```sql
-- In sql/v0.1.0_install.sql:
INSERT INTO `holycow_slots` (...) VALUES
(1, DEINE_X, DEINE_Y, DEINE_Z, HEADING),
...
```

**Option B: Nach Installation updaten**
```sql
UPDATE holycow_slots SET pos_x = X, pos_y = Y, pos_z = Z WHERE slot_number = 1;
```

---

## 🎮 Nutzung

### **Als Spieler:**

1. Gehe zur Farm (Blip auf Map)
2. Finde den NPC (Farmer mit Clipboard)
3. E drücken → "Kühe kaufen"
4. Wähle Rasse + Slot
5. Kaufen!
6. Kuh spawnt automatisch

### **Als Admin:**

```bash
# Debug Commands:
/holycow_list      # Alle Kühe anzeigen
/holycow_slots     # Freie Slots anzeigen
/holycow_reset     # ALLES löschen (VORSICHT!)
/holycow_shop      # Shop öffnen (Test)
```

---

## ⚙️ Konfiguration

Alles in `config.lua`:

```lua
-- Farm Location
Config.Farm.Blip.Coords = vector3(x, y, z)

-- NPC Position
Config.ShopNPC.Coords = vector4(x, y, z, heading)

-- Kuh-Typen
Config.CowTypes = { ... }

-- Preise
Config.CowTypes[1].price = 500  -- Holstein
Config.CowTypes[2].price = 1200 -- Jersey
```

---

## 🏗️ Datenbankstruktur

```
holycow_types      - Kuh-Rassen (Templates)
holycow_slots      - Positionen auf dem Hof
holycow_owned      - Besessene Kühe (Player)
holycow_version    - Version-Tracking
```

---

## 🔧 Troubleshooting

### **Kühe spawnen nicht**

```bash
# Check:
1. SQL ausgeführt?
2. Slots in DB vorhanden? → /holycow_slots
3. F8 Console Errors?
4. oxmysql läuft?
```

### **NPC nicht da**

```lua
-- config.lua:
Config.ShopNPC.Enabled = true
Config.ShopNPC.Coords = vector4(...) -- Richtige Koordinaten?
```

### **Shop öffnet nicht**

```bash
# Check:
1. ox_target installiert?
2. F8 Console: "ox_target added to NPC"?
3. Test: /holycow_shop
```

---

## 🚀 Roadmap

### **v0.2.0 - Stats System (nächste Woche)**
- 4-Stats: Gesundheit, Hunger, Sauberkeit, Laune
- Füttern (3 Futter-Typen)
- Stats-Anzeige in UI

### **v0.3.0 - Growth System**
- 3 Stages: Kalb → Jungtier → Erwachsen
- Alterung über Zeit
- Stage-basierte Features

### **v0.4.0 - Production**
- Melken!
- Zustandsbasierter Ertrag
- Cooldowns

### **v1.0.0 - Release!**
- Alle Features poliert
- Balance-Testing
- Dokumentation

---

## ❓ FAQ

**Q: Kann ich mehr als 6 Kühe haben?**
A: In v0.1.0: Nein. Später kommt Slot-Upgrade-System.

**Q: Was macht Jersey besser als Holstein?**
A: In v0.1.0: Noch nichts (Stats kommen in v0.2.0+)

**Q: Kann ich Kühe verkaufen?**
A: Noch nicht. Kommt in v0.6.0.

**Q: Warum kann ich nicht melken?**
A: v0.1.0 ist nur Foundation. Melken kommt v0.4.0!

---

## 📝 Changelog

### [0.1.0] - Foundation
- Kauf-System
- Slot-Management
- Spawning
- MySQL-Integration
- Shop-UI

---

## 🐄 Credits

**Made with ❤️ by HM Scripts**

Dank an:
- ox_lib Team
- ox_target Team
- FiveM Community

---

**Version:** 0.1.0  
**Status:** Foundation ✅  
**Next:** v0.2.0 - Stats System

🐄 **HOLY COW!** 🐄
