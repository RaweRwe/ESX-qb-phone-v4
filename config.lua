Config = {}
Config.RepeatTimeout = 2000
Config.CallRepeats = 10
Config.OpenPhone = 288

-- Configs
Config.Language = 'en' -- You have more translations in html.
Config.Webhook = '' -- Your Webhook.
Config.Tokovoip = false -- If it is true it will use Tokovoip, if it is false it will use Mumblevoip.
Config.Job = 'police' -- If you want, you can choose another job and it is the job that will appear in the 'Police' application, modify the html to make it another job.
Config.UseESXLicense = true
Config.UseESXBilling = true

Config.Languages = {
    ['en'] = {
        ["NO_VEHICLE"] = "No vehicle around!",
        ["NO_ONE"] = "No one around!",
        ["ALLFIELDS"] = "Fields must be filled!",

        ["RACE_TITLE"] = "Racing",

        ["WHATSAPP_TITLE"] = "Whatsapp",
        ["WHATSAPP_NEW_MESSAGE"] = "New message from",
        ["WHATSAPP_MESSAGE_TOYOU"] = "Why are you sending messages to yourself you sadfuck?",
        ["WHATSAPP_LOCATION_SET"] = "Location is set!",
        ["WHATSAPP_SHARED_LOCATION"] = "Shared Location",
        ["WHATSAPP_BLANK_MSG"] = "You cannot send a blank message!",

        ["MAIL_TITLE"] = "Mail",
        ["MAIL_NEW"] = "You received an email from this person: ",

        ["ADVERTISEMENT_TITLE"] = "Yellow Pages",
        ["ADVERTISEMENT_NEW"] = "There is an advertisement on the yellow pages!",
        ["ADVERTISEMENT_EMPY"] = "You must enter a message!",

        ["TWITTER_TITLE"] = "Twitter",
        ["TWITTER_NEW"] = "New Tweet",
        ["TWITTER_POSTED"] = "The tweet has been posted!",
        ["TWITTER_GETMENTIONED"] = "You tagged in a tweet!",
        ["MENTION_YOURSELF"] = "You can't talk about yourself!",
        ["TWITTER_ENTER_MSG"] = "You must enter a message!",

        ["PHONE_DONT_HAVE"] = "You don't have a phone!",
        ["PHONE_TITLE"] = "Guide",
        ["PHONE_CALL_END"] = "The call has ended",
        ["PHONE_NOINCOMING"] = "You have no incoming call!",
        ["PHONE_STARTED_ANON"] = "You have started an anonymous call!",
        ["PHONE_BUSY"] = "You are already busy!",
        ["PHONE_PERSON_TALKING"] = "This person is talking!",
        ["PHONE_PERSON_UNAVAILABLE"] = "This person is not available!",
        ["PHONE_YOUR_NUMBER"] = "You can't call yourself!",
        ["PHONE_MSG_YOURSELF"] = "You can't message yourself!",

        ["CONTACTS_REMOVED"] = "The person has been deleted!",
        ["CONTACTS_NEWSUGGESTED"] = "You have a new suggested contact!",
        ["CONTACTS_EDIT_TITLE"] = "Contact Edit",
        ["CONTACTS_ADD_TITLE"] = "Guide",

        ["BANK_TITLE"] = 'Bank',
        ["BANK_DONT_ENOUGH"] = 'You dont have enough money!',
        ["BANK_NOIBAN"] = "There is no IBAN associated with this person!",

        ["CRYPTO_TITLE"] = "Crypto",

        ["GPS_SET"] = "GPS Location set: ",

        ["NUI_SYSTEM"] = 'System',
        ["NUI_NOT_AVAILABLE"] = 'is not available!',
        ["NUI_MYPHONE"] = 'Phone Number',
        ["NUI_INFO"] = 'Information',

        ["SETTINGS_TITLE"] = 'Settings',
        ["PROFILE_SET"] = 'Own profile picture set!',
        ["POFILE_DEFAULT"] = 'Profile picture has been reset to default!',
        ["BACKGROUND_SET"] = 'Own background set!',

        ["RACING_TITLE"] = "Racing",
        ["RACING_CHOSEN_TRACK"] = "You have not chosen a Track.",
        ["RACING_ALREADY_ACTIVE"] = "You already have a race active.",
        ["RACING_ENTER_ROUNDS"] = "Enter an amount of rounds.",
        ["RACING_CANT_THIS_TIME"] = "No races can be made at this time.",
        ["RACING_ALREADY_STARTED"] = "The race has already started.",
        ["RACING_ALREADY_INRACE"] = "You're already in a race.",
        ["RACING_ALREADY_CREATED"] = "You are already creating a Track.",
        ["RACING_INEDITOR"] = "You're in an editor.",
        ["RACING_INRACE"] = "You're in a race.",
        ["RACING_CANTSTART"] = "You have no rights to create Race Track's.",
        ["RACING_CANTTHISNAME"] = "This name is not available.",
        ["RACING_ENTER_TRACK"] = "You must enter a Track name.",

        ["MEOS_TITLE"] = "MEOS",
        ["MEOS_CLEARED"] = "All notifications have been removed!",
        ["MEOS_GPS"] = "This message has no GPS Location!",
        ["MEOS_NORESULT"] = "There is not result!",

	},
	
}

Config.PhoneApplications = {
    ["phone"] = {
        app = "phone",
        color = "#04b543",
        icon = "fa fa-phone-alt",
        tooltipText = "Phone",
        tooltipPos = "top",
        job = false,
        blockedjobs = {},
        slot = 1,
        Alerts = 0,
    },
    ["whatsapp"] = {
        app = "whatsapp",
        color = "#25d366",
        icon = "fab fa-whatsapp",
        tooltipText = "Whatsapp",
        tooltipPos = "top",
        style = "font-size: 2.8vh";
        job = false,
        blockedjobs = {},
        slot = 2,
        Alerts = 0,
    },
    ["twitter"] = {
        app = "twitter",
        color = "#1da1f2",
        icon = "fab fa-twitter",
        tooltipText = "Twitter",
        tooltipPos = "top",
        job = false,
        blockedjobs = {},
        slot = 3,
        Alerts = 0,
    },
    ["settings"] = {
        app = "settings",
        color = "#636e72",
        icon = "fa fa-cog",
        tooltipText = "Settings",
        tooltipPos = "top",
        style = "padding-right: .08vh; font-size: 2.3vh";
        job = false,
        blockedjobs = {},
        slot = 4,
        Alerts = 0,
    },
    ["garage"] = {
        app = "garage",
        color = "#575fcf",
        icon = "fas fa-warehouse",
        tooltipText = "Vehicles",
        job = false,
        blockedjobs = {},
        slot = 5,
        Alerts = 0,
    },
    ["mail"] = {
        app = "mail",
        color = "#ff002f",
        icon = "fas fa-envelope",
        tooltipText = "Mail",
        job = false,
        blockedjobs = {},
        slot = 6,
        Alerts = 0,
    },
    ["advert"] = {
        app = "advert",
        color = "#ff8f1a",
        icon = "fas fa-ad",
        tooltipText = "Adverts",
        job = false,
        blockedjobs = {},
        slot = 7,
        Alerts = 0,
    },
    ["bank"] = {
        app = "bank",
        color = "#9c88ff",
        icon = "fas fa-university",
        tooltipText = "Bank",
        job = false,
        blockedjobs = {},
        slot = 8,
        Alerts = 0,
    },
    ["racing"] = {
        app = "racing",
        color = "#353b48",
        icon = "fas fa-flag-checkered",
        tooltipText = "Racing",
        job = false,
        blockedjobs = {},
        slot = 9,
        Alerts = 0,
    },
    ["lawyers"] = {
        app = "lawyers",
        color = "#0061e0",
        icon = "fas fa-building",
        tooltipText = "Polices",
        job = false,
        blockedjobs = {},
        slot = 10,
        Alerts = 0,
    },
    ["spotify"] = {
        app = "spotify",
        color = "#82c91e",
        icon = "fab fa-spotify",
        tooltipText = "Spotify",
        job = false,
        blockedjobs = {},
        slot = 11,
        Alerts = 0,
    },  
    ["bbc"] = {
        app = "bbc",
        color = "#ff0000",
        icon = "fas fa-newspaper",
        tooltipText = "Qbus News",
        job = false,
        blockedjobs = {},
        slot = 12,
        Alerts = 0,
    },
    ["snake"] = {
        app = "snake",
        color = "#609",
        icon = "fas fa-ghost",
        tooltipText = "Snake Game",
        job = false,
        blockedjobs = {},
        slot = 13,
        Alerts = 0,
    },
    ["solitary"] = {
        app = "solitary",
        color = "#e6bb12",
        icon = "fas fa-crown",
        tooltipText = "Solitary",
        job = false,
        blockedjobs = {},
        slot = 14,
        Alerts = 0,
    },
--[[    ["meos"] = {
        app = "meos",
        color = "#004682",
        icon = "fas fa-ad",
        tooltipText = "MEOS",
        job = "police",
        blockedjobs = {},
        slot = 15,
        Alerts = 0,
    },  ]]--
}