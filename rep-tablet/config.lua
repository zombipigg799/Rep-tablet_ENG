Config = {}
-- Config add job and event directives here, vpn = true requires VPN to be shown
Config.JobCenter = {
    ['towing'] = {
        vpn = false,
        label = "Towing",
        event = "rep-tablet:jobcenter:tow",
        mem = 2, -- Max number of people in a group
        count = 0, -- Don't touch
        salary = 'high',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fas fa-car-crash"

    },
    ['taxi'] = {
        vpn = false,
        label = "Taxi",
        event = "rep-tablet:jobcenter:taxi",
        mem = 1,
        count = 0,
        salary = 'mid',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fa-solid fa-taxi"
    },
    ['thefthouse'] = {
        vpn = true,
        label = "House Robbery",
        event = "sn-houserobbery:client:chiduong",
        mem = 3,
        count = 0,
        salary = 'low',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fa-solid fa-mask"
    },
    ['oxyrun'] = {
        vpn = true,
        label = "Oxy Run",
        event = "rep-oxyrun:client:chiduong",
        mem = 2,
        count = 0,
        salary = 'mid',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fa-solid fa-pills"
    },
    ['theftcar'] = {
        vpn = true,
        label = "Chop Shop",
        event = "rep-chopshop:client:chiduong",
        mem = 2,
        count = 0,
        salary = 'mid',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fas fa-lock-open"
    },
    ['postop'] = {
        vpn = false,
        label = "PostOp Worker",
        event = "rep-tablet:jobcenter:postop",
        mem = 4,
        count = 0,
        salary = 'high',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fa-solid fa-truck-fast"
    },
    ['sani'] = {
        vpn = false,
        label = "Sanitation Worker",
        event = "rep-tablet:jobcenter:sanitation",
        mem = 4,
        count = 0,
        salary = 'mid',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fas fa-trash"
    },
    ['taco'] = {
        vpn = true,
        label = "Taco Shop",
        event = "rep-weed:client:chiduong",
        mem = 2,
        count = 0,
        salary = 'mid',
        time = {
            first = 2500,
            second = 10000,
        },
        icon = "fas fa-cannabis"
    },
}

-- They will be randomized when they have a VPN
Config.FirstName = {
    'Trump',
    'Musk',
    'Adams',
    'Harrison',
    'Taft',
    'Long',
    'Lodge',
    'Kennedy',
    'Bayh',
    'Indiana',
    'Brown',
    'Miller',
    'Davis',
    'Garcia',
}
-- The name will be random when you have a VPN
Config.LastName = {
    'James',
    'Robert',
    'John',
    'Michael',
    'Cheng',
    'BahnMy',
    'Cris',
    'Hwan',
    'William'
}