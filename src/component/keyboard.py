from telegram import InlineKeyboardMarkup, InlineKeyboardButton

from src.connector.kb_utils import get_kb_check_start, get_kb_city

#TODO: Aggiungere query per ritrovare filtri su regione

# ****** Buttons ******

btn_add_start = InlineKeyboardButton(text="Aggiungi nuova bolletta", callback_data="add")
btn_check_start = InlineKeyboardButton(text="Confronta prezzi fornitori", callback_data="check_start")

btn_add_login = InlineKeyboardButton(text="Login", callback_data="login")
btn_add_register = InlineKeyboardButton(text="Registrati", callback_data="register")

# ****** Keyboards ******

kb_start = InlineKeyboardMarkup([[btn_add_start], [btn_check_start]])
kb_auth = InlineKeyboardMarkup([[btn_add_login], [btn_add_register]])

# TODO: The following keyboards needs to be made dynamically, depending on the user response
kb_check_start = InlineKeyboardMarkup(get_kb_check_start())
kb_city = InlineKeyboardMarkup(get_kb_city("Campania"))
