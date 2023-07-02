#include <amxmodx>  // Библиотека AMX Mod X
#include <fakemeta> // Библиотека FakeMeta
#include <cstrike>  // Библиотека CS
#include <colorchat> // Библиотека ColorChat

static const PLUGIN_NAME[]  = "Ownage hns"; // Название плагина
static const PLUGIN_AUTHOR[] = "hpp forever"; // Автор плагина
static const PLUGIN_VERSION[] = "1.2"; // Версия плагина

new Float: Block[33]; // Массив для хранения времени блокировки игроков

new const Sounds[3][] = { // Массив со звуковыми файлами
    "mario.wav", "ownage.wav", "ownage2.wav"
};

public plugin_precache() {
    precache_sound("mario.wav"); // Предзагружаем звуковой файл
	precache_sound("ownage.wav");
    precache_sound("ownage2.wav");
}

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR); // Регистрируем плагин
    register_forward(FM_Touch, "fwd_Owning"); // Регистрируем форвард
}

public client_connect(id) {
    Block[id] = get_gametime(); // Записываем время подключения игрока
}

public fwd_Owning(owned, owner) {
    static OwnedClassname[32], OwnerClassname[32];
    pev(owned, pev_classname, OwnedClassname, 31); // Получаем класс объекта, которым управляет "owned"
    pev(owner, pev_classname, OwnerClassname, 31); // Получаем класс объекта, которым управляет "owner"
    
    if (!equal(OwnedClassname, "player") || !equal(OwnerClassname, "player")) return FMRES_IGNORED; // Если объекты не являются игроками, игнорируем
    
    if (!is_user_ok(owned) || !is_user_ok(owner)) return FMRES_IGNORED; // Если игроки не подходят по условиям, игнорируем
    
    if (cs_get_user_team(owner) == CS_TEAM_CT || cs_get_user_team(owner) == cs_get_user_team(owned)) return FMRES_IGNORED; // Если игроки в одной команде, игнорируем

    static Float: OwnedOrigin[3], Float: OwnerOrigin[3];
    pev(owned, pev_origin, OwnedOrigin); // Получаем позицию игрока "owned"
    pev(owner, pev_origin, OwnerOrigin); // Получаем позицию игрока "owner"
        
    new Float: OwnDistance = OwnerOrigin[2] - OwnedOrigin[2]; // Вычисляем разницу высоты между игроками
        
    if (OwnDistance >= 35) { // Если разница высоты больше или равна 35
        if (get_gametime() - Block[owner] > 3.0) { // Если прошло больше 3-х секунд с момента последнего блока
            new name[32], name2[32];
            get_user_name(owner, name, 31); // Получаем имя игрока "owner"
            get_user_name(owned, name2, 31); // Получаем имя игрока "owned"
            set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), -1.0, 0.3, 0, 6.0, 10.0); // Устанавливаем сообщение на HUD
			
            show_hudmessage(0, "%s Оседлал суку %s", name, name2); // Отображаем сообщение на HUD
			
            client_cmd(0,"spk sound/%s",Sounds[random(sizeof Sounds)]); // Воспроизводим случайный звуковой файл
			
            ShakeScreen(owned); // Трясем экран игрока "owned"
            FadeScreen(owned); // Затухаем экран игрока "owned"
            Block[owner] = get_gametime(); // Записываем время блокировки
            return FMRES_IGNORED; // Игнорируем остальные форварды
        }
    }

    return FMRES_IGNORED; // Игнорируем остальные форварды
}

stock is_user_ok(id) {
    if (is_user_alive(id) && is_user_connected(id) && !is_user_bot(id)) // Проверяем, что игрок жив, подключен и не является ботом
        return 1; // Возвращаем 1, если игрок подходит по условиям
        
    return 0; // Возвращаем 0, если игрок не подходит по условиям
}

ShakeScreen(id) {
    message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0, 0, 0}, id); // Создаем сообщение для тряски экрана
    write_short(floatround(4096.0 * 3.0, floatround_round)); // Записываем значения для тряски
    write_short(floatround(4096.0 * 3.0, floatround_round));
    write_short(1 << 13);
    message_end(); // Завершаем сообщение
}

FadeScreen(id) {  
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id); // Создаем сообщение для затухания экрана
    write_short(floatround(4096.0 * 3.0, floatround_round)); // Записываем значения для затухания
    write_short(floatround(4096.0 * 3.0, floatround_round));
    write_short(0x0000);
    write_byte(random_num(0,255));
    write_byte(random_num(0,255));
    write_byte(random_num(0,255));
    write_byte(110);
    message_end(); // Завершаем сообщение
}