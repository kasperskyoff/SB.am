# 🔆 SB.am - SunBox Admin Menu
Админская система администрирования для Garry's Mod, предназначен только для сервера Солнечный Sandbox.
## 🔆 Возможности

- **Продвинутая система прав**
  - Семейственная структура рангов с уровнями иммунитета
  - Настраиваемые цвета рангов и интеграция с командами
  - Автоматическое сихронизация рангов с базой данной

- **Фреймворк команд**
  - Простая система создания команд
  - Использование команды с @
  - Категории команд

- **Инструменты администратора**
  - Система банов/разбанов с базой данной
  - Система тюрьмы
  - Функционал мута/размута
  - Режим Build
  - Режим PvP
  - Управление игроками (кик, убийство и т.д.)
  - Логирование в консоль администратора/сервера

- **GUI (Graphical User Interface)**
  - Меню
  - Панель ввода аргументов
  - Кнопка принятие аргумента
  - Список игроков
  - Категории команд

- **Удобные функции**
  - Команды в чате с несколькими префиксами (!, /, .)
  - Интеграция цветные ранги с чатом
  - Система публичных объявлений (PSA)

## 🛠️ Установка
1. Скачайте репозиторий и папку `SB.am` с `lua` перекиньте в addons (например, `ВАШ_ДИСК:\test\garrysmod\addons` для сервера)
2. Можете настроить ранги `lua/sb.am/shared/sh_sbam.lua`
3. Перезапустите сервер

## 📝 Конфигурация
Основные файлы конфигурации:
- `lua/sb.am/shared/sh_sbam.lua` - Права и ранги
- `lua/sb.am/shared/sh_category.lua` - Категории команд
- `lua/sb.am/shared/sh_func.lua` - Весь функционал
- `lua/sb.am/sql/sql_sb.am.lua` - Структура базы данных

## 📒 Документация
Прочитайте пожалуйста [Wiki](https://github.com/rkaspersky/SB.am/wiki/SB.am-Wiki)! Чтобы узнать как создавать команды и использовать саму систему.

## ⚠️ Важно
Я повторюсь, что `SB.am` сделана только для сервера Солнечный Sandbox. Если вы хотите использовать на своих серверах, будьте готовы ко всему.
