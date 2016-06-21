//
//  Header.h
//  FDR Calibration
//
//  Created by Torres on 13-11-11.
//  Copyright (c) 2013年 Torres. All rights reserved.
//

#ifndef FDR_Calibration_Header_h
#define FDR_Calibration_Header_h

typedef enum USNumber{
    
    /* Numbers */
    n_0 =          29,      /* 0 */
    n_1 =          18,      /* 1 */
    n_2 =          19,      /* 2 */
    n_3 =          20,      /* 3 */
    n_4 =          21,      /* 4 */
    n_5 =          23,      /* 5 */
    n_6 =          22,      /* 6 */
    n_7 =          26,      /* 7 */
    n_8 =          28,      /* 8 */
    n_9 =          25,      /* 9 */
}_USNumber;

typedef enum USKeyCode {
    A =           0,      /* A */
    B =          11,      /* B */
    C =           8,      /* C */
    D =           2,      /* D */
    E =          14,      /* E */
    F =           3,      /* F */
    G =           5,      /* G */
    H =           4,      /* H */
    I =          34,      /* I */
    J =          38,      /* J */
    K =          40,      /* K */
    L =          37,      /* L */
    M =          46,      /* M */
    N =          45,      /* N */
    O =          31,      /* O */
    P =          35,      /* P */
    Q =          12,      /* Q */
    R =          15,      /* R */
    S =           1,      /* S */
    T =          17,      /* T */
    U =          32,      /* U */
    V =           9,      /* V */
    W =          13,      /* W */
    X =           7,      /* X */
    Y =          16,      /* Y */
    Z =           6,      /* Z */
    a =           0,      /* a */
    b =          11,      /* b */
    c =           8,      /* c */
    d =           2,      /* d */
    e =          14,      /* e */
    f =           3,      /* f */
    g =           5,      /* g */
    h =           4,      /* h */
    i =          34,      /* i */
    j =          38,      /* j */
    k =          40,      /* k */
    l =          37,      /* l */
    m =          46,      /* m */
    n =          45,      /* n */
    o =          31,      /* o */
    p =          35,      /* p */
    q =          12,      /* q */
    r =          15,      /* r */
    s =           1,      /* s */
    t =          17,      /* t */
    u =          32,      /* u */
    v =           9,      /* v */
    w =          13,      /* w */
    x =           7,      /* x */
    y =          16,      /* y */
    z =           6,      /* z */
    
    /* Symbols */
    exclam =     18,      /* ! */
    at =         19,      /* @ */
    numbersign = 20,      /* # */
    dollar =     21,      /* $ */
    percent =    23,      /* % */
    asciicircum =22,      /* ^ */
    ampersand =  26,      /* & */
    asterisk =   28,      /* * */
    parenleft =  25,      /* ( */
    parenright = 29,      /* ) */
    minus =      27,      /* - */
    underscore = 27,      /* _ */
    equal =      24,      /* = */
    plus =       24,      /* + */
    grave =      50,      /* ` */  /* XXX ? */
    asciitilde = 50,      /* ~ */
    bracketleft =33,      /* [ */
    braceleft =  33,      /* { */
    bracketright=30,      /* ] */
    braceright = 30,      /* } */
    semicolon =  41,      /* ; */
    colon =      41,      /* : */
    apostrophe = 39,      /* ' */
    quotedbl =   39,      /* " */
    comma =      43,      /* , */
    less =       43,      /* < */
    period =     47,      /* . */
    greater =    47,      /* > */
    slash =      44,      /* / */
    question =   44,      /* ? */
    backslash =  42,      /* \ */
    bar =        42,      /* | */
    space =      49,      /* Space */
}_USKeyCode;

typedef enum SpecialKeyCode{
    /* "Special" keys */
    Return =     36,      /* Return */
    Delete =    117,      /* Delete */
    Tab =        48,      /* Tab */
    Escape =     53,      /* Esc */
    Caps_Lock =  57,      /* Caps Lock */
    Num_Lock =   71,      /* Num Lock */
    Scroll_Lock=107,      /* Scroll Lock */
    Pause =     113,      /* Pause */
    BackSpace =  51,      /* Backspace */
    Insert =    114,      /* Insert */
    
    /* Cursor movement */
    Up =        126,      /* Cursor Up */
    Down =      125,      /* Cursor Down */
    Left =      123,      /* Cursor Left */
    Right =     124,      /* Cursor Right */
    Page_Up =   116,      /* Page Up */
    Page_Down = 121,      /* Page Down */
    Home =      115,      /* Home */
    End =       119,      /* End */
    
    /* Numeric keypad */
    KP_0 =       82,      /* KP 0 */
    KP_1 =       83,      /* KP 1 */
    KP_2 =       84,      /* KP 2 */
    KP_3 =       85,      /* KP 3 */
    KP_4 =       86,      /* KP 4 */
    KP_5 =       87,      /* KP 5 */
    KP_6 =       88,      /* KP 6 */
    KP_7 =       89,      /* KP 7 */
    KP_8 =       91,      /* KP 8 */
    KP_9 =       92,      /* KP 9 */
    KP_Enter =   76,      /* KP Enter */
    KP_Decimal = 65,      /* KP . */
    KP_Add =     69,      /* KP + */
    KP_Subtract =78,      /* KP - */
    KP_Multiply =67,      /* KP * */
    KP_Divide =  75,      /* KP / */
    
    /* Function keys */
    F1 =        122,      /* F1 */
    F2 =        120,      /* F2 */
    F3 =         99,      /* F3 */
    F4 =        118,      /* F4 */
    F5 =         96,      /* F5 */
    F6 =         97,      /* F6 */
    F7 =         98,      /* F7 */
    F8 =        100,      /* F8 */
    F9 =        101,      /* F9 */
    F10 =       109,      /* F10 */
    F11 =       103,      /* F11 */
    F12 =       111,      /* F12 */
    
    /* Modifier keys */
    Alt_L =      55,      /* Alt Left (-> Command) */
    Alt_R =      55,      /* Alt Right (-> Command) */
    Shift_L =    56,      /* Shift Left */
    Shift_R =    56,      /* Shift Right */
    Meta_L =     58,      /* Option Left (-> Option) */
    Meta_R =     58,      /* Option Right (-> Option) */
    Super_L =    58,      /* Option Left (-> Option) */
    Super_R =    58,      /* Option Right (-> Option) */
    Control_L =  59,      /* Ctrl Left */
    Control_R =  59,      /* Ctrl Right */
}_SpecialKeyCode;
//static int USKeyCodes[] = {
//    /* The alphabet */
//    A =           0,      /* A */
//    B =          11,      /* B */
//    C =           8,      /* C */
//    D =           2,      /* D */
//    E =          14,      /* E */
//    F =           3,      /* F */
//    G =           5,      /* G */
//    H =           4,      /* H */
//    I =          34,      /* I */
//    J =          38,      /* J */
//    K =          40,      /* K */
//    L =          37,      /* L */
//    M =          46,      /* M */
//    N =          45,      /* N */
//    O =          31,      /* O */
//    P =          35,      /* P */
//    Q =          12,      /* Q */
//    R =          15,      /* R */
//    S =           1,      /* S */
//    T =          17,      /* T */
//    U =          32,      /* U */
//    V =           9,      /* V */
//    W =          13,      /* W */
//    X =           7,      /* X */
//    Y =          16,      /* Y */
//    Z =           6,      /* Z */
//    a =           0,      /* a */
//    b =          11,      /* b */
//    c =           8,      /* c */
//    d =           2,      /* d */
//    e =          14,      /* e */
//    f =           3,      /* f */
//    g =           5,      /* g */
//    h =           4,      /* h */
//    i =          34,      /* i */
//    j =          38,      /* j */
//    k =          40,      /* k */
//    l =          37,      /* l */
//    m =          46,      /* m */
//    n =          45,      /* n */
//    o =          31,      /* o */
//    p =          35,      /* p */
//    q =          12,      /* q */
//    r =          15,      /* r */
//    s =           1,      /* s */
//    t =          17,      /* t */
//    u =          32,      /* u */
//    v =           9,      /* v */
//    w =          13,      /* w */
//    x =           7,      /* x */
//    y =          16,      /* y */
//    z =           6,      /* z */
//    
//    /* Numbers */
//    0 =          29,      /* 0 */
//    1 =          18,      /* 1 */
//    2 =          19,      /* 2 */
//    3 =          20,      /* 3 */
//    4 =          21,      /* 4 */
//    5 =          23,      /* 5 */
//    6 =          22,      /* 6 */
//    7 =          26,      /* 7 */
//    8 =          28,      /* 8 */
//    9 =          25,      /* 9 */
//    
//    /* Symbols */
//    exclam =     18,      /* ! */
//    at =         19,      /* @ */
//    numbersign = 20,      /* # */
//    dollar =     21,      /* $ */
//    percent =    23,      /* % */
//    asciicircum =22,      /* ^ */
//    ampersand =  26,      /* & */
//    asterisk =   28,      /* * */
//    parenleft =  25,      /* ( */
//    parenright = 29,      /* ) */
//    minus =      27,      /* - */
//    underscore = 27,      /* _ */
//    equal =      24,      /* = */
//    plus =       24,      /* + */
//    grave =      50,      /* ` */  /* XXX ? */
//    asciitilde = 50,      /* ~ */
//    bracketleft =33,      /* [ */
//    braceleft =  33,      /* { */
//    bracketright,      30,      /* ] */
//    braceright = 30,      /* } */
//    semicolon =  41,      /* ; */
//    colon =      41,      /* : */
//    apostrophe = 39,      /* ' */
//    quotedbl =   39,      /* " */
//    comma =      43,      /* , */
//    less =       43,      /* < */
//    period =     47,      /* . */
//    greater =    47,      /* > */
//    slash =      44,      /* / */
//    question =   44,      /* ? */
//    backslash =  42,      /* \ */
//    bar =        42,      /* | */
//    space =      49,      /* Space */
//};
//
//static int SpecialKeyCodes[] = {
//    /* "Special" keys */
//    XK_Return,            36,      /* Return */
//    XK_Delete,           117,      /* Delete */
//    XK_Tab,               48,      /* Tab */
//    XK_Escape,            53,      /* Esc */
//    XK_Caps_Lock,         57,      /* Caps Lock */
//    XK_Num_Lock,          71,      /* Num Lock */
//    XK_Scroll_Lock,      107,      /* Scroll Lock */
//    XK_Pause,            113,      /* Pause */
//    XK_BackSpace,         51,      /* Backspace */
//    XK_Insert,           114,      /* Insert */
//
//    /* Cursor movement */
//    XK_Up,               126,      /* Cursor Up */
//    XK_Down,             125,      /* Cursor Down */
//    XK_Left,             123,      /* Cursor Left */
//    XK_Right,            124,      /* Cursor Right */
//    XK_Page_Up,          116,      /* Page Up */
//    XK_Page_Down,        121,      /* Page Down */
//    XK_Home,             115,      /* Home */
//    XK_End,              119,      /* End */
//
//    /* Numeric keypad */
//    XK_KP_0,              82,      /* KP 0 */
//    XK_KP_1,              83,      /* KP 1 */
//    XK_KP_2,              84,      /* KP 2 */
//    XK_KP_3,              85,      /* KP 3 */
//    XK_KP_4,              86,      /* KP 4 */
//    XK_KP_5,              87,      /* KP 5 */
//    XK_KP_6,              88,      /* KP 6 */
//    XK_KP_7,              89,      /* KP 7 */
//    XK_KP_8,              91,      /* KP 8 */
//    XK_KP_9,              92,      /* KP 9 */
//    XK_KP_Enter,          76,      /* KP Enter */
//    XK_KP_Decimal,        65,      /* KP . */
//    XK_KP_Add,            69,      /* KP + */
//    XK_KP_Subtract,       78,      /* KP - */
//    XK_KP_Multiply,       67,      /* KP * */
//    XK_KP_Divide,         75,      /* KP / */
//
//    /* Function keys */
//    XK_F1,               122,      /* F1 */
//    XK_F2,               120,      /* F2 */
//    XK_F3,                99,      /* F3 */
//    XK_F4,               118,      /* F4 */
//    XK_F5,                96,      /* F5 */
//    XK_F6,                97,      /* F6 */
//    XK_F7,                98,      /* F7 */
//    XK_F8,               100,      /* F8 */
//    XK_F9,               101,      /* F9 */
//    XK_F10,              109,      /* F10 */
//    XK_F11,              103,      /* F11 */
//    XK_F12,              111,      /* F12 */
//
//    /* Modifier keys */
//    XK_Alt_L,             55,      /* Alt Left (-> Command) */
//    XK_Alt_R,             55,      /* Alt Right (-> Command) */
//    XK_Shift_L,           56,      /* Shift Left */
//    XK_Shift_R,           56,      /* Shift Right */
//    XK_Meta_L,            58,      /* Option Left (-> Option) */
//    XK_Meta_R,            58,      /* Option Right (-> Option) */
//    XK_Super_L,           58,      /* Option Left (-> Option) */
//    XK_Super_R,           58,      /* Option Right (-> Option) */
//    XK_Control_L,         59,      /* Ctrl Left */
//    XK_Control_R,         59,      /* Ctrl Right */
//};

#endif
