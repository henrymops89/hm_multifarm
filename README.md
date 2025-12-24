# 🐄🐔🐷 Multi-Farm v0.3.0

**Farm Management System mit Kühen, Hühnern und Schweinen**

---

## ✨ **Features**

### **3 Tierarten:**
- 🐄 **Kühe** - 5 Rassen, Milch sammeln (15 Min Cooldown)
- 🐔 **Hühner** - 3 Rassen, Eier sammeln (10 Min Cooldown)
- 🐷 **Schweine** - 3 Rassen, Füttern & Fleisch (20 Min Cooldown)

### **30 Slots total:**
- 10 Kuh-Slots
- 10 Hühner-Slots
- 10 Schweine-Slots

### **3 NPCs:**
- Kuh-Farmer (Grapeseed)
- Hühner-Züchter (Grapeseed Nord)
- Schweine-Züchter (Grapeseed Ost)

### **Gameplay:**
- Verschiedene Rassen mit Stats (Gesundheit, Wachstum, Produktion)
- Cooldown-System
- ox_lib Menu UI
- Blips für alle Tiere
- Custom Namen
- Debug-Commands

---

## 📋 **Installation**

### **1. Dateien kopieren:**
```
resources/[custom]/multifarm/
```

### **2. SQL ausführen:**
```sql
-- Execute: docs/schema.sql
-- WICHTIG: Koordinaten anpassen wenn nötig!
```

### **3. Items hinzufügen:**
Kopiere Items aus `docs/items.lua` nach `ox_inventory/data/items.lua`:
```lua
-- Kühe
'milk_bucket', 'milk_stool', 'raw_milk'

-- Hühner
'eggs'

-- Schweine
'pig_feed', 'pork'
```

### **4. Config anpassen:**
```lua
-- config.lua
Config.Framework = 'qbox'  -- oder 'qbcore', 'esx'

-- NPC Positionen anpassen wenn gewünscht:
Config.NPCs.cow.Coords = vector4(...)
Config.NPCs.chicken.Coords = vector4(...)
Config.NPCs.pig.Coords = vector4(...)
```

### **5. Permissions:**
```lua
-- server.cfg
add_ace group.admin multifarm.admin allow
```

### **6. Resource starten:**
```
ensure multifarm
```

---

## 🎮 **Wie spielen?**

### **Kühe:**
1. Gehe zum **Kuh-Farmer** NPC
2. Kaufe eine Kuh (5 Rassen: $500-$1800)
3. Wähle einen Slot
4. **Melken:** Benötigt Melkeimer + Melkschemel
5. Cooldown: 15 Minute

### **Hühner:**
1. Gehe zum **Hühner-Züchter** NPC
2. Kaufe ein Huhn (3 Rassen: $150-$800)
3. Wähle einen Slot
4. **Eier sammeln:** Keine Items benötigt!
5. Cooldown: 10 Minuten

### **Schweine:**
1. Gehe zum **Schweine-Züchter** NPC
2. Kaufe ein Schwein (3 Rassen: $600-$2000)
3. Wähle einen Slot
4. **Füttern:** Benötigt Schweinefutter!
5. Cooldown: 20 Minuten

---

## 🐄 **Kuh-Rassen**

| Rasse | Preis | Seltenheit | Milch | Beschreibung |
|-------|-------|-----------|-------|--------------|
| Holstein-Friesian | $500 | Common | 3x | Standard Milchkuh |
| Jersey Premium | $1200 | Rare | 5x | 50% schnelleres Wachstum |
| Black Angus | $900 | Uncommon | 2x | Robuste Fleischrasse |
| Schweizer Braunvieh | $1500 | Rare | 4x | Perfekt für Käse |
| Simmental Elite | $1800 | Epic | 6x | Beste Milchproduktion |

---

## 🐔 **Hühner-Rassen**

| Rasse | Preis | Seltenheit | Eier | Beschreibung |
|-------|-------|-----------|------|--------------|
| Legehennen | $150 | Common | 2x | Standard Hühner |
| Premium-Huhn | $400 | Rare | 4x | Doppelte Eierproduktion |
| Gold-Huhn | $800 | Epic | 6x | Elite-Rasse, beste Eier |

---

## 🐷 **Schweine-Rassen**

| Rasse | Preis | Seltenheit | Fleisch | Beschreibung |
|-------|-------|-----------|---------|--------------|
| Hausschwein | $600 | Common | 2x | Standard Mastschwein |
| Mastschwein | $1200 | Rare | 4x | Doppelte Fleischausbeute |
| Premium-Schwein | $2000 | Epic | 6x | Elite-Rasse, bestes Fleisch |

---

## 🛠️ **Debug Commands**

### **Admin-Commands (brauchen ACE):**
```
/multifarm_list          - Alle Tiere anzeigen
/multifarm_slots         - Slot-Status
/multifarm_cleanup       - Zombie Slots fixen
/multifarm_reset         - ALLE Tiere löschen (VORSICHT!)
```

### **Player-Commands (Debug = true):**
```
/multifarm_cow_shop      - Kuh-Shop öffnen
/multifarm_chicken_shop  - Hühner-Shop öffnen
/multifarm_pig_shop      - Schweine-Shop öffnen
```

---

## 📊 **Items**

### **Kühe:**
- `milk_bucket` - Melkeimer (benötigt)
- `milk_stool` - Melkschemel (benötigt)
- `raw_milk` - Rohmilch (Produkt)

### **Hühner:**
- `eggs` - Eier (Produkt)

### **Schweine:**
- `pig_feed` - Schweinefutter (benötigt, wird verbraucht!)
- `pork` - Schweinefleisch (Produkt)

---

## ⚙️ **Config Highlights**

```lua
-- Permissions
Config.Permissions = {
    MaxAnimals = 30,     -- Gesamt
    MaxCows = 10,
    MaxChickens = 10,
    MaxPigs = 10,
}

-- Milking (Kühe)
Config.Milking = {
    CooldownMinutes = 15,
    RequireItems = true,
}

-- Egg Collection (Hühner)
Config.EggCollection = {
    CooldownMinutes = 10,
    RequireItems = false,  -- Keine Items!
}

-- Pig Feeding (Schweine)
Config.PigFeeding = {
    CooldownMinutes = 20,
    RequireItems = true,     -- Futter benötigt!
    RemoveItemsAfterUse = true,  -- Futter wird verbraucht!
}
```

---

## 🐛 **Troubleshooting**

### **Tiere spawnen nicht:**
1. Check F8 Console für Errors
2. Sind die Models korrekt? (`a_c_cow`, `a_c_hen`, `a_c_pig`)
3. SQL korrekt ausgeführt?

### **NPCs spawnen nicht:**
1. Koordinaten in Config prüfen
2. Models existieren? (`a_m_m_farmer_01`, `a_m_m_hillbilly_01`)

### **Cooldown funktioniert nicht:**
1. Server-Uhrzeit korrekt?
2. MySQL Timezone richtig?

### **Items verschwinden:**
1. ox_inventory installiert?
2. Items in `items.lua` hinzugefügt?

---

## 📝 **Changelog**

### **v0.3.0 (Latest)**
- ✅ Hühner hinzugefügt (3 Rassen)
- ✅ Schweine hinzugefügt (3 Rassen)
- ✅ 3 separate NPCs
- ✅ 30 Slots total (10 pro Tierart)
- ✅ Fütter-System für Schweine
- ✅ Eier-Sammel-System für Hühner
- ✅ Multi-Tier Database-Schema

### **v0.2.1**
- ✅ DATETIME Bug gefixt
- ✅ Zombie Slots Auto-Cleanup
- ✅ ox_target Race Condition gefixt
- ✅ 5 Kuh-Rassen

---

## 💬 **Support**

Bei Problemen:
1. Check Console (F8)
2. Check Server Console
3. Lies TROUBLESHOOTING oben

---

## 📜 **Credits**

- **Original:** HM Holy Cow by HM Scripts
- **Framework:** ox_lib, ox_target, oxmysql

---

**Viel Spaß beim Farmen! 🐄🐔🐷**
