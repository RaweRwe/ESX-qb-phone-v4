ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Code

local QBPhone = {}
local Tweets = {}
local AppAlerts = {}
local MentionedTweets = {}
local Hashtags = {}
local Calls = {}
local Adverts = {}
local GeneratedPlates = {}

RegisterServerEvent('gov-phone:server:AddAdvert')
AddEventHandler('gov-phone:server:AddAdvert', function(msg)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local CitizenId = Player.PlayerData.citizenid

    if Adverts[CitizenId] ~= nil then
        Adverts[CitizenId].message = msg
        Adverts[CitizenId].name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname
        Adverts[CitizenId].number = Player.PlayerData.charinfo.phone
    else
        Adverts[CitizenId] = {
            message = msg,
            name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname,
            number = Player.PlayerData.charinfo.phone,
        }
    end

    TriggerClientEvent('gov-phone:client:UpdateAdverts', -1, Adverts, "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname)
end)

function GetOnlineStatus(number)
    local Target = ESX.GetPlayerFromIdByPhone(number)
    local retval = false
    if Target ~= nil then retval = true end
    return retval
end
					
ESX.RegisterServerCallback('gov-phone:server:GetPhoneData', function(source, cb)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if Player ~= nil then
        local PhoneData = {
            Applications = {},
            PlayerContacts = {},
            MentionedTweets = {},
            Chats = {},
            Hashtags = {},
			SelfTweets = {},
            Invoices = {},
            Garage = {},
            Mails = {},
            Adverts = {},
            CryptoTransactions = {},
            Tweets = {}
        }

        PhoneData.Adverts = Adverts

        ESX.ExecuteSql(false, "SELECT * FROM player_contacts WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' ORDER BY `name` ASC", function(result)
            local Contacts = {}
            if result[1] ~= nil then
                for k, v in pairs(result) do
                    v.status = GetOnlineStatus(v.number)
                end
                
                PhoneData.PlayerContacts = result
            end
			
            ESX.ExecuteSql(false, "SELECT * FROM twitter_tweets", function(result)
                if result[1] ~= nil then
                    PhoneData.Tweets = result
                else
                    PhoneData.Tweets = nil
                end


                ESX.ExecuteSql(false, "SELECT * FROM twitter_tweets WHERE owner = '"..Player.PlayerData.citizenid.."'", function(result)
                    if result ~= nil then
                        PhoneData.SelfTweets = result
     
                    end

			
            ESX.ExecuteSql(false, "SELECT * FROM phone_invoices WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(invoices)
                if invoices[1] ~= nil then
                    for k, v in pairs(invoices) do
                        local Ply = ESX.GetPlayerFromIdByCitizenId(v.sender)
                        if Ply ~= nil then
                            v.number = Ply.PlayerData.charinfo.phone
                        else
                            ESX.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
                                if res[1] ~= nil then
                                    res[1].charinfo = json.decode(res[1].charinfo)
                                    v.number = res[1].charinfo.phone
                                else
                                    v.number = nil
                                end
                            end)
                        end
                    end
                    PhoneData.Invoices = invoices
                end
                
                ESX.ExecuteSql(false, "SELECT * FROM player_vehicles WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(garageresult)
                    if garageresult[1] ~= nil then
                        -- for k, v in pairs(garageresult) do
                        --     if (GOVCore.Shared.Vehicles[v.vehicle] ~= nil) and (Garages[v.garage] ~= nil) then
                        --         v.garage = Garages[v.garage].label
                        --         v.vehicle = GOVCore.Shared.Vehicles[v.vehicle].name
                        --         v.brand = GOVCore.Shared.Vehicles[v.vehicle].brand
                        --     end
                        -- end

                        PhoneData.Garage = garageresult
                    end
                    
                    ESX.ExecuteSql(false, "SELECT * FROM phone_messages WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(messages)
                        if messages ~= nil and next(messages) ~= nil then 
                            PhoneData.Chats = messages
                        end

                        if AppAlerts[Player.PlayerData.citizenid] ~= nil then 
                            PhoneData.Applications = AppAlerts[Player.PlayerData.citizenid]
                        end

                        if MentionedTweets[Player.PlayerData.citizenid] ~= nil then 
                            PhoneData.MentionedTweets = MentionedTweets[Player.PlayerData.citizenid]
                        end

                        if Hashtags ~= nil and next(Hashtags) ~= nil then
                            PhoneData.Hashtags = Hashtags
                        end

                        if Tweets ~= nil and next(Tweets) ~= nil then
                            PhoneData.Tweets = Tweets
                        end

                        ESX.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(mails)
                            if mails[1] ~= nil then
                                for k, v in pairs(mails) do
                                    if mails[k].button ~= nil then
                                        mails[k].button = json.decode(mails[k].button)
                                    end
                                end
                                PhoneData.Mails = mails
                            end

                            ESX.ExecuteSql(false, 'SELECT * FROM `crypto_transactions` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(transactions)
                                if transactions[1] ~= nil then
                                    for _, v in pairs(transactions) do
                                        table.insert(PhoneData.CryptoTransactions, {
                                            TransactionTitle = v.title,
                                            TransactionMessage = v.message,
                                        })
                                    end
                                end
    
                                cb(PhoneData)
                            end)
                        end)
                    end)
                end)
            end)
			end)
			end)
        end)
    end
end)

ESX.RegisterServerCallback('gov-phone:server:GetCallState', function(source, cb, ContactData)
    local Target = ESX.GetPlayerFromIdByPhone(ContactData.number)

    if Target ~= nil then
        if Calls[Target.PlayerData.citizenid] ~= nil then
            if Calls[Target.PlayerData.citizenid].inCall then
                cb(false, true)
            else
                cb(true, true)
            end
        else
            cb(true, true)
        end
    else
        cb(false, false)
    end
end)

RegisterServerEvent('gov-phone:server:SetCallState')
AddEventHandler('gov-phone:server:SetCallState', function(bool)
    local src = source
    local Ply = ESX.GetPlayerFromId(src)

    if Calls[Ply.PlayerData.citizenid] ~= nil then
        Calls[Ply.PlayerData.citizenid].inCall = bool
    else
        Calls[Ply.PlayerData.citizenid] = {}
        Calls[Ply.PlayerData.citizenid].inCall = bool
    end
end)

RegisterServerEvent('gov-phone:server:RemoveMail')
AddEventHandler('gov-phone:server:RemoveMail', function(MailId)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, 'DELETE FROM `player_mails` WHERE `mailid` = "'..MailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
    SetTimeout(100, function()
        ESX.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('gov-phone:client:UpdateMails', src, mails)
        end)
    end)
end)

function GenerateMailId()
    return math.random(111111, 999999)
end

RegisterServerEvent('gov-phone:server:sendNewMail')
AddEventHandler('gov-phone:server:sendNewMail', function(mailData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    if mailData.button == nil then
        ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
    else
        ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
    end
    TriggerClientEvent('gov-phone:client:NewMailNotify', src, mailData)
    SetTimeout(200, function()
        ESX.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('gov-phone:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('gov-phone:server:sendNewMailToOffline')
AddEventHandler('gov-phone:server:sendNewMailToOffline', function(citizenid, mailData)
    local Player = ESX.GetPlayerFromIdByCitizenId(citizenid)

    if Player ~= nil then
        local src = Player.PlayerData.source

        if mailData.button == nil then
            ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
            TriggerClientEvent('gov-phone:client:NewMailNotify', src, mailData)
        else
            ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
            TriggerClientEvent('gov-phone:client:NewMailNotify', src, mailData)
        end

        SetTimeout(200, function()
            ESX.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
                if mails[1] ~= nil then
                    for k, v in pairs(mails) do
                        if mails[k].button ~= nil then
                            mails[k].button = json.decode(mails[k].button)
                        end
                    end
                end
        
                TriggerClientEvent('gov-phone:client:UpdateMails', src, mails)
            end)
        end)
    else
        if mailData.button == nil then
            ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
        else
            ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
        end
    end
end)

RegisterServerEvent('gov-phone:server:sendNewEventMail')
AddEventHandler('gov-phone:server:sendNewEventMail', function(citizenid, mailData)
    if mailData.button == nil then
        ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
    else
        ESX.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
    end
    SetTimeout(200, function()
        ESX.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('gov-phone:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('gov-phone:server:ClearButtonData')
AddEventHandler('gov-phone:server:ClearButtonData', function(mailId)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, 'UPDATE `player_mails` SET `button` = "" WHERE `mailid` = "'..mailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
    SetTimeout(200, function()
        ESX.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('gov-phone:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('gov-phone:server:MentionedPlayer')
AddEventHandler('gov-phone:server:MentionedPlayer', function(firstName, lastName, TweetMessage)
    for k, v in pairs(ESX.GetPlayerFromIds()) do
        local Player = ESX.GetPlayerFromId(v)
        if Player ~= nil then
            if (Player.PlayerData.charinfo.firstname == firstName and Player.PlayerData.charinfo.lastname == lastName) then
                QBPhone.SetPhoneAlerts(Player.PlayerData.citizenid, "twitter")
                QBPhone.AddMentionedTweet(Player.PlayerData.citizenid, TweetMessage)
                TriggerClientEvent('gov-phone:client:GetMentioned', Player.PlayerData.source, TweetMessage, AppAlerts[Player.PlayerData.citizenid]["twitter"])
            else
                ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..firstName.."%' AND `charinfo` LIKE '%"..lastName.."%'", function(result)
                    if result[1] ~= nil then
                        local MentionedTarget = result[1].citizenid
                        QBPhone.SetPhoneAlerts(MentionedTarget, "twitter")
                        QBPhone.AddMentionedTweet(MentionedTarget, TweetMessage)
                    end
                end)
            end
        end
	end
end)

RegisterServerEvent('gov-phone:server:CallContact')
AddEventHandler('gov-phone:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local Ply = ESX.GetPlayerFromId(src)
    local Target = ESX.GetPlayerFromIdByPhone(TargetData.number)

    if Target ~= nil then
        TriggerClientEvent('gov-phone:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall)
    end
end)

ESX.RegisterServerCallback('gov-phone:server:PayInvoice', function(source, cb, sender, amount, invoiceId)
    local src = source
    local Ply = ESX.GetPlayerFromId(src)
    local Trgt = ESX.GetPlayerFromIdByCitizenId(sender)
    local Invoices = {}

    if Trgt ~= nil then
        if Ply.PlayerData.money.bank >= amount then
            Ply.Functions.RemoveMoney('bank', amount, "paid-invoice")
            Trgt.Functions.AddMoney('bank', amount, "paid-invoice")

            ESX.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `invoiceid` = '"..invoiceId.."'")
            ESX.ExecuteSql(false, "SELECT * FROM `phone_invoices` WHERE `citizenid` = '"..Ply.PlayerData.citizenid.."'", function(invoices)
                if invoices[1] ~= nil then
                    for k, v in pairs(invoices) do
                        local Target = ESX.GetPlayerFromIdByCitizenId(v.sender)
                        if Target ~= nil then
                            v.number = Target.PlayerData.charinfo.phone
                        else
                            ESX.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
                                if res[1] ~= nil then
                                    res[1].charinfo = json.decode(res[1].charinfo)
                                    v.number = res[1].charinfo.phone
                                else
                                    v.number = nil
                                end
                            end)
                        end
                    end
                    Invoices = invoices
                end
                cb(true, Invoices)
            end)
        else
            cb(false)
        end
    else
        ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '"..sender.."'", function(result)
            if result[1] ~= nil then
                local moneyInfo = json.decode(result[1].money)
                moneyInfo.bank = math.ceil((moneyInfo.bank + amount))
                ESX.ExecuteSql(true, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..sender.."'")
                Ply.Functions.RemoveMoney('bank', amount, "paid-invoice")
                ESX.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `invoiceid` = '"..invoiceId.."'")
                ESX.ExecuteSql(false, "SELECT * FROM `phone_invoices` WHERE `citizenid` = '"..Ply.PlayerData.citizenid.."'", function(invoices)
                    if invoices[1] ~= nil then
                        for k, v in pairs(invoices) do
                            local Target = ESX.GetPlayerFromIdByCitizenId(v.sender)
                            if Target ~= nil then
                                v.number = Target.PlayerData.charinfo.phone
                            else
                                ESX.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
                                    if res[1] ~= nil then
                                        res[1].charinfo = json.decode(res[1].charinfo)
                                        v.number = res[1].charinfo.phone
                                    else
                                        v.number = nil
                                    end
                                end)
                            end
                        end
                        Invoices = invoices
                    end
                    cb(true, Invoices)
                end)
            else
                cb(false)
            end
        end)
    end
end)

ESX.RegisterServerCallback('gov-phone:server:DeclineInvoice', function(source, cb, sender, amount, invoiceId)
    local src = source
    local Ply = ESX.GetPlayerFromId(src)
    local Trgt = ESX.GetPlayerFromIdByCitizenId(sender)
    local Invoices = {}

    ESX.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `invoiceid` = '"..invoiceId.."'")
    ESX.ExecuteSql(false, "SELECT * FROM `phone_invoices` WHERE `citizenid` = '"..Ply.PlayerData.citizenid.."'", function(invoices)
        if invoices[1] ~= nil then
            for k, v in pairs(invoices) do
                local Target = ESX.GetPlayerFromIdByCitizenId(v.sender)
                if Target ~= nil then
                    v.number = Target.PlayerData.charinfo.phone
                else
                    ESX.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
                        if res[1] ~= nil then
                            res[1].charinfo = json.decode(res[1].charinfo)
                            v.number = res[1].charinfo.phone
                        else
                            v.number = nil
                        end
                    end)
                end
            end
            Invoices = invoices
        end
        cb(true, invoices)
    end)
end)

RegisterServerEvent('gov-phone:server:UpdateHashtags')
AddEventHandler('gov-phone:server:UpdateHashtags', function(Handle, messageData)
    if Hashtags[Handle] ~= nil and next(Hashtags[Handle]) ~= nil then
        table.insert(Hashtags[Handle].messages, messageData)
    else
        Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        table.insert(Hashtags[Handle].messages, messageData)
    end
    TriggerClientEvent('gov-phone:client:UpdateHashtags', -1, Handle, messageData)
end)

RegisterServerEvent('lucid_phone:deleteTweet')
AddEventHandler('lucid_phone:deleteTweet', function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    exports['ghmattimysql']:execute('DELETE FROM twitter_tweets WHERE owner = @owner AND id = @id', {['@owner'] = xPlayer.PlayerData.citizenid, ['@id'] = id})
end)


RegisterServerEvent('gov-phone:server:UpdateTweets')
AddEventHandler('gov-phone:server:UpdateTweets', function(TweetData, type)
    Tweets = NewTweets
    local TwtData = TweetData
    local src = source
    TriggerClientEvent('gov-phone:client:UpdateTweets', -1, src, TwtData, type)
end)


QBPhone.AddMentionedTweet = function(citizenid, TweetData)
    if MentionedTweets[citizenid] == nil then MentionedTweets[citizenid] = {} end
    table.insert(MentionedTweets[citizenid], TweetData)
end

QBPhone.SetPhoneAlerts = function(citizenid, app, alerts)
    if citizenid ~= nil and app ~= nil then
        if AppAlerts[citizenid] == nil then
            AppAlerts[citizenid] = {}
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = alerts
                end
            end
        else
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = 0
                end
            else
                if alerts == nil then
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 1
                else
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 0
                end
            end
        end
    end
end

ESX.RegisterServerCallback('gov-phone:server:GetContactPictures', function(source, cb, Chats)
    for k, v in pairs(Chats) do
        local Player = ESX.GetPlayerFromIdByPhone(v.number)
        
        ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..v.number.."%'", function(result)
            if result[1] ~= nil then
                local MetaData = json.decode(result[1].metadata)

                if MetaData.phone.profilepicture ~= nil then
                    v.picture = MetaData.phone.profilepicture
                else
                    v.picture = "default"
                end
            end
        end)
    end
    SetTimeout(100, function()
        cb(Chats)
    end)
end)

ESX.RegisterServerCallback('gov-phone:server:GetContactPicture', function(source, cb, Chat)
    local Player = ESX.GetPlayerFromIdByPhone(Chat.number)

    ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..Chat.number.."%'", function(result)
        local MetaData = json.decode(result[1].metadata)

        if MetaData.phone.profilepicture ~= nil then
            Chat.picture = MetaData.phone.profilepicture
        else
            Chat.picture = "default"
        end
    end)
    SetTimeout(100, function()
        cb(Chat)
    end)
end)


RegisterServerEvent('lucid_phone:saveTwitterToDatabase')
AddEventHandler('lucid_phone:saveTwitterToDatabase', function(firstName, lastname, message, url, time, picture)
    local xPlayer = ESX.GetPlayerFromId(source)

	exports['ghmattimysql']:execute('INSERT INTO twitter_tweets (firstname, lastname, message, url, time, picture, owner) VALUES (@firstname, @lastname, @message, @url, @time, @picture, @owner)',
	{
		['@firstname']   	= firstName,
		['@lastname']   	= lastname,
		['@message'] 	= message,
        ['@url']       = url,
		['@time']  = time,
        ['@picture'] 		= picture,
        ['@owner'] 		= xPlayer.PlayerData.citizenid,

	})
end)

RegisterServerEvent('lucid_phone:server:updateForEveryone')
AddEventHandler('lucid_phone:server:updateForEveryone', function(newTweet)
    local src = source
    print('has work')
    TriggerClientEvent('lucid_phone:updateForEveryone', -1, newTweet)
end)

RegisterServerEvent('lucid_phone:server:updateidForEveryone')
AddEventHandler('lucid_phone:server:updateidForEveryone', function()
    TriggerClientEvent('lucid_phone:updateidForEveryone', -1)
end)


ESX.RegisterServerCallback('gov-phone:server:GetPicture', function(source, cb, number)
    local Player = ESX.GetPlayerFromIdByPhone(number)
    local Picture = nil

    ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..number.."%'", function(result)
        if result[1] ~= nil then
            local MetaData = json.decode(result[1].metadata)

            if MetaData.phone.profilepicture ~= nil then
                Picture = MetaData.phone.profilepicture
            else
                Picture = "default"
            end
            cb(Picture)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('gov-phone:server:SetPhoneAlerts')
AddEventHandler('gov-phone:server:SetPhoneAlerts', function(app, alerts)
    local src = source
    local CitizenId = ESX.GetPlayerFromId(src).citizenid
    QBPhone.SetPhoneAlerts(CitizenId, app, alerts)
end)

RegisterServerEvent('gov-phone:server:UpdateTweets')
AddEventHandler('gov-phone:server:UpdateTweets', function(NewTweets, TweetData)
    Tweets = NewTweets
    local TwtData = TweetData
    local src = source
    TriggerClientEvent('gov-phone:client:UpdateTweets', -1, src, Tweets, TwtData)
end)

RegisterServerEvent('gov-phone:server:TransferMoney')
AddEventHandler('gov-phone:server:TransferMoney', function(iban, amount)
    local src = source
    local sender = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..iban.."%'", function(result)
        if result[1] ~= nil then
            local recieverSteam = ESX.GetPlayerFromIdByCitizenId(result[1].citizenid)

            if recieverSteam ~= nil then
                local PhoneItem = recieverSteam.Functions.GetItemByName("phone")
                recieverSteam.Functions.AddMoney('bank', amount, "phone-transfered-from-"..sender.PlayerData.citizenid)
                sender.Functions.RemoveMoney('bank', amount, "phone-transfered-to-"..recieverSteam.PlayerData.citizenid)

                if PhoneItem ~= nil then
                    TriggerClientEvent('gov-phone:client:TransferMoney', recieverSteam.PlayerData.source, amount, recieverSteam.PlayerData.money.bank)
                end
            else
                local moneyInfo = json.decode(result[1].money)
                moneyInfo.bank = round((moneyInfo.bank + amount))
                ESX.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                sender.Functions.RemoveMoney('bank', amount, "phone-transfered")
            end
        else
            exports['mythic_notify']:DoHudText('error', 'This account number does not exist!')
        end
    end)
end)

RegisterServerEvent('gov-phone:server:EditContact')
AddEventHandler('gov-phone:server:EditContact', function(newName, newNumber, newIban, oldName, oldNumber, oldIban)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    ESX.ExecuteSql(false, "UPDATE `player_contacts` SET `name` = '"..newName.."', `number` = '"..newNumber.."', `iban` = '"..newIban.."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `name` = '"..oldName.."' AND `number` = '"..oldNumber.."'")
end)

RegisterServerEvent('gov-phone:server:RemoveContact')
AddEventHandler('gov-phone:server:RemoveContact', function(Name, Number)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    
    ESX.ExecuteSql(false, "DELETE FROM `player_contacts` WHERE `name` = '"..Name.."' AND `number` = '"..Number.."' AND `citizenid` = '"..Player.PlayerData.citizenid.."'")
end)

RegisterServerEvent('gov-phone:server:AddNewContact')
AddEventHandler('gov-phone:server:AddNewContact', function(name, number, iban)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, "INSERT INTO `player_contacts` (`citizenid`, `name`, `number`, `iban`) VALUES ('"..Player.PlayerData.citizenid.."', '"..tostring(name).."', '"..tostring(number).."', '"..tostring(iban).."')")
end)

RegisterServerEvent('gov-phone:server:UpdateMessages')
AddEventHandler('gov-phone:server:UpdateMessages', function(ChatMessages, ChatNumber, New)
    local src = source
    local SenderData = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..ChatNumber.."%'", function(Player)
        if Player[1] ~= nil then
            local TargetData = ESX.GetPlayerFromIdByCitizenId(Player[1].citizenid)

            if TargetData ~= nil then
                ESX.ExecuteSql(false, "SELECT * FROM `phone_messages` WHERE `citizenid` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..ChatNumber.."'", function(Chat)
                    if Chat[1] ~= nil then
                        -- Update for target
                        ESX.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `citizenid` = '"..TargetData.PlayerData.citizenid.."' AND `number` = '"..SenderData.PlayerData.charinfo.phone.."'")
                                
                        -- Update for sender
                        ESX.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `citizenid` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..TargetData.PlayerData.charinfo.phone.."'")
                    
                        -- Send notification & Update messages for target
                        TriggerClientEvent('gov-phone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, false)
                    else
                        -- Insert for target
                        ESX.ExecuteSql(false, "INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES ('"..TargetData.PlayerData.citizenid.."', '"..SenderData.PlayerData.charinfo.phone.."', '"..json.encode(ChatMessages).."')")
                                            
                        -- Insert for sender
                        ESX.ExecuteSql(false, "INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES ('"..SenderData.PlayerData.citizenid.."', '"..TargetData.PlayerData.charinfo.phone.."', '"..json.encode(ChatMessages).."')")

                        -- Send notification & Update messages for target
                        TriggerClientEvent('gov-phone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, true)
                    end
                end)
            else
                ESX.ExecuteSql(false, "SELECT * FROM `phone_messages` WHERE `citizenid` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..ChatNumber.."'", function(Chat)
                    if Chat[1] ~= nil then
                        -- Update for target
                        ESX.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `citizenid` = '"..Player[1].citizenid.."' AND `number` = '"..SenderData.PlayerData.charinfo.phone.."'")
                                
                        -- Update for sender
                        Player[1].charinfo = json.decode(Player[1].charinfo)
                        ESX.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `citizenid` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..Player[1].charinfo.phone.."'")
                    else
                        -- Insert for target
                        ESX.ExecuteSql(false, "INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES ('"..Player[1].citizenid.."', '"..SenderData.PlayerData.charinfo.phone.."', '"..json.encode(ChatMessages).."')")
                        
                        -- Insert for sender
                        Player[1].charinfo = json.decode(Player[1].charinfo)
                        ESX.ExecuteSql(false, "INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES ('"..SenderData.PlayerData.citizenid.."', '"..Player[1].charinfo.phone.."', '"..json.encode(ChatMessages).."')")
                    end
                end)
            end
        end
    end)
end)

RegisterServerEvent('gov-phone:server:AddRecentCall')
AddEventHandler('gov-phone:server:AddRecentCall', function(type, data)
    local src = source
    local Ply = ESX.GetPlayerFromId(src)

    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour..":"..Minute

    TriggerClientEvent('gov-phone:client:AddRecentCall', src, data, label, type)

    local Trgt = ESX.GetPlayerFromIdByPhone(data.number)
    if Trgt ~= nil then
        TriggerClientEvent('gov-phone:client:AddRecentCall', Trgt.PlayerData.source, {
            name = Ply.PlayerData.charinfo.firstname .. " " ..Ply.PlayerData.charinfo.lastname,
            number = Ply.PlayerData.charinfo.phone,
            anonymous = anonymous
        }, label, "outgoing")
    end
end)

RegisterServerEvent('gov-phone:server:CancelCall')
AddEventHandler('gov-phone:server:CancelCall', function(ContactData)
    local Ply = ESX.GetPlayerFromIdByPhone(ContactData.TargetData.number)

    if Ply ~= nil then
        TriggerClientEvent('gov-phone:client:CancelCall', Ply.PlayerData.source)
    end
end)

RegisterServerEvent('gov-phone:server:AnswerCall')
AddEventHandler('gov-phone:server:AnswerCall', function(CallData)
    local Ply = ESX.GetPlayerFromIdByPhone(CallData.TargetData.number)

    if Ply ~= nil then
        TriggerClientEvent('gov-phone:client:AnswerCall', Ply.PlayerData.source)
    end
end)

RegisterServerEvent('gov-phone:server:SaveMetaData')
AddEventHandler('gov-phone:server:SaveMetaData', function(MData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        local MetaData = json.decode(result[1].metadata)
        MetaData.phone = MData
        ESX.ExecuteSql(false, "UPDATE `players` SET `metadata` = '"..json.encode(MetaData).."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
    end)

    Player.Functions.SetMetaData("phone", MData)
end)

function escape_sqli(source)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return source:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end

ESX.RegisterServerCallback('gov-phone:server:FetchResult', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    local ApaData = {}
    ESX.ExecuteSql(false, 'SELECT * FROM `players` WHERE `citizenid` = "'..search..'" OR `charinfo` LIKE "%'..search..'%"', function(result)
        ESX.ExecuteSql(false, 'SELECT * FROM `apartments`', function(ApartmentData)
            for k, v in pairs(ApartmentData) do
                ApaData[v.citizenid] = ApartmentData[k]
            end

            if result[1] ~= nil then
                for k, v in pairs(result) do
                    local charinfo = json.decode(v.charinfo)
                    local metadata = json.decode(v.metadata)
                    local appiepappie = {}
                    if ApaData[v.citizenid] ~= nil and next(ApaData[v.citizenid]) ~= nil then
                        appiepappie = ApaData[v.citizenid]
                    end
                    table.insert(searchData, {
                        citizenid = v.citizenid,
                        firstname = charinfo.firstname,
                        lastname = charinfo.lastname,
                        birthdate = charinfo.birthdate,
                        phone = charinfo.phone,
                        nationality = charinfo.nationality,
                        gender = charinfo.gender,
                        warrant = false,
                        driverlicense = metadata["licences"]["driver"],
                        appartmentdata = appiepappie,
                    })
                end
                cb(searchData)
            else
                cb(nil)
            end
        end)
    end)
end)

ESX.RegisterServerCallback('gov-phone:server:GetVehicleSearchResults', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    ESX.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` LIKE "%'..search..'%" OR `citizenid` = "'..search..'"', function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                ESX.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[k].citizenid..'"', function(player)
                    if player[1] ~= nil then 
                        local charinfo = json.decode(player[1].charinfo)
                        local vehicleInfo = GOVCore.Shared.Vehicles[result[k].vehicle]
                        if vehicleInfo ~= nil then 
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = vehicleInfo["name"]
                            })
                        else
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = "Name not found.."
                            })
                        end
                    end
                end)
            end
        else
            if GeneratedPlates[search] ~= nil then
                table.insert(searchData, {
                    plate = GeneratedPlates[search].plate,
                    status = GeneratedPlates[search].status,
                    owner = GeneratedPlates[search].owner,
                    citizenid = GeneratedPlates[search].citizenid,
                    label = "Brand unknown.."
                })
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[search] = {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                table.insert(searchData, {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                    label = "Brand unknown.."
                })
            end
        end
        cb(searchData)
    end)
end)

ESX.RegisterServerCallback('gov-phone:server:ScanPlate', function(source, cb, plate)
    local src = source
    local vehicleData = {}
    if plate ~= nil then 
        ESX.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` = "'..plate..'"', function(result)
            if result[1] ~= nil then
                ESX.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[1].citizenid..'"', function(player)
                    local charinfo = json.decode(player[1].charinfo)
                    vehicleData = {
                        plate = plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[1].citizenid,
                    }
                end)
            elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then 
                vehicleData = GeneratedPlates[plate]
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[plate] = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                vehicleData = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
            end
            cb(vehicleData)
        end)
    else
        exports['mythic_notify']:DoHudText('error', 'No vehicle around..')
        cb(nil)
    end
end)

function GenerateOwnerName()
    local names = {
        [1] = { name = "Jan Bloksteen", citizenid = "DSH091G93" },
        [2] = { name = "Jay Dendam", citizenid = "AVH09M193" },
        [3] = { name = "Ben Klaariskees", citizenid = "DVH091T93" },
        [4] = { name = "Karel Bakker", citizenid = "GZP091G93" },
        [5] = { name = "Klaas Adriaan", citizenid = "DRH09Z193" },
        [6] = { name = "Nico Wolters", citizenid = "KGV091J93" },
        [7] = { name = "Mark Hendrickx", citizenid = "ODF09S193" },
        [8] = { name = "Bert Johannes", citizenid = "KSD0919H3" },
        [9] = { name = "Karel de Grote", citizenid = "NDX091D93" },
        [10] = { name = "Jan Pieter", citizenid = "ZAL0919X3" },
        [11] = { name = "Huig Roelink", citizenid = "ZAK09D193" },
        [12] = { name = "Corneel Boerselman", citizenid = "POL09F193" },
        [13] = { name = "Hermen Klein Overmeen", citizenid = "TEW0J9193" },
        [14] = { name = "Bart Rielink", citizenid = "YOO09H193" },
        [15] = { name = "Antoon Henselijn", citizenid = "QBC091H93" },
        [16] = { name = "Aad Keizer", citizenid = "YDN091H93" },
        [17] = { name = "Thijn Kiel", citizenid = "PJD09D193" },
        [18] = { name = "Henkie Krikhaar", citizenid = "RND091D93" },
        [19] = { name = "Teun Blaauwkamp", citizenid = "QWE091A93" },
        [20] = { name = "Dries Stielstra", citizenid = "KJH0919M3" },
        [21] = { name = "Karlijn Hensbergen", citizenid = "ZXC09D193" },
        [22] = { name = "Aafke van Daalen", citizenid = "XYZ0919C3" },
        [23] = { name = "Door Leeferds", citizenid = "ZYX0919F3" },
        [24] = { name = "Nelleke Broedersen", citizenid = "IOP091O93" },
        [25] = { name = "Renske de Raaf", citizenid = "PIO091R93" },
        [26] = { name = "Krisje Moltman", citizenid = "LEK091X93" },
        [27] = { name = "Mirre Steevens", citizenid = "ALG091Y93" },
        [28] = { name = "Joosje Kalvenhaar", citizenid = "YUR09E193" },
        [29] = { name = "Mirte Ellenbroek", citizenid = "SOM091W93" },
        [30] = { name = "Marlieke Meilink", citizenid = "KAS09193" },
    }
    return names[math.random(1, #names)]
end

ESX.RegisterServerCallback('gov-phone:server:GetGarageVehicles', function(source, cb)
    local Player = ESX.GetPlayerFromId(source)
    local Vehicles = {}

    ESX.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                local VehicleData = GOVCore.Shared.Vehicles[v.vehicle]

                local VehicleGarage = "Geen"
                if v.garage ~= nil then
                    if Garages[v.garage] ~= nil then
                        VehicleGarage = Garages[v.garage]["label"]
                    end
                end

                local VehicleState = "In"
                if v.state == 0 then
                    VehicleState = "Uit"
                elseif v.state == 2 then
                    VehicleState = "In Beslag"
                end

                local vehdata = {}

                if VehicleData["brand"] ~= nil then
                    vehdata = {
                        fullname = VehicleData["brand"] .. " " .. VehicleData["name"],
                        brand = VehicleData["brand"],
                        model = VehicleData["name"],
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = VehicleState,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }
                else
                    vehdata = {
                        fullname = VehicleData["name"],
                        brand = VehicleData["name"],
                        model = VehicleData["name"],
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = VehicleState,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }
                end

                table.insert(Vehicles, vehdata)
            end
            cb(Vehicles)
        else
            cb(nil)
        end
    end)
end)

ESX.RegisterServerCallback('gov-phone:server:HasPhone', function(source, cb)
    local Player = ESX.GetPlayerFromId(source)
    
    if Player ~= nil then
        local HasPhone = Player.Functions.GetItemByName("phone")
        local retval = false

        if HasPhone ~= nil then
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterServerEvent('gov-phone:server:GiveContactDetails')
AddEventHandler('gov-phone:server:GiveContactDetails', function(PlayerId)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    local SuggestionData = {
        name = {
            [1] = Player.PlayerData.charinfo.firstname,
            [2] = Player.PlayerData.charinfo.lastname
        },
        number = Player.PlayerData.charinfo.phone,
        bank = Player.PlayerData.charinfo.account
    }

    TriggerClientEvent('gov-phone:client:AddNewSuggestion', PlayerId, SuggestionData)
end)

RegisterServerEvent('gov-phone:server:AddTransaction')
AddEventHandler('gov-phone:server:AddTransaction', function(data)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, "INSERT INTO `crypto_transactions` (`citizenid`, `title`, `message`) VALUES ('"..Player.PlayerData.citizenid.."', '"..escape_sqli(data.TransactionTitle).."', '"..escape_sqli(data.TransactionMessage).."')")
end)

ESX.RegisterServerCallback('gov-phone:server:GetCurrentpolices', function(source, cb)
    local polices = {}
    for k, v in pairs(ESX.GetPlayerFromIds()) do
        local Player = ESX.GetPlayerFromId(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "police" then
                table.insert(polices, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(polices)
end)

ESX.RegisterServerCallback('gov-phone:server:GetCurrentLawyers', function(source, cb)
    local Lawyers = {}
    for k, v in pairs(ESX.GetPlayerFromIds()) do
        local Player = ESX.GetPlayerFromId(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "lawyer" then
                table.insert(Lawyers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(Lawyers)
end)

RegisterServerEvent('gov-phone:server:postTweet')
AddEventHandler('gov-phone:server:postTweet', function(message)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    
    ESX.ExecuteSql(false, "INSERT INTO `phone_tweets` (`citizenid`, `sender`, `message`) VALUES ('"..Player.PlayerData.citizenid.."', '"..Player.PlayerData.charinfo.firstname.." "..string.sub(Player.PlayerData.charinfo.lastname, 1, 1):upper()..".', '"..message.."')")
    TriggerClientEvent('gov-phone:client:newTweet', -1, Player.PlayerData.charinfo.firstname.." "..string.sub(Player.PlayerData.charinfo.lastname, 1, 1):upper()..".", message)
end)


ESX.RegisterServerCallback("gov-phone:server:getPhoneTweets", function(source, cb)
    local src = source
    local pData = ESX.GetPlayerFromId(src)

    ESX.ExecuteSql(false, 'SELECT * FROM `phone_tweets` ORDER BY `date` DESC', function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

ESX.RegisterServerCallback('gov-phone:server:GetCurrentDrivers', function(source, cb)
    local drivers = {}
    for k, v in pairs(ESX.GetPlayerFromIds()) do
        local Player = ESX.GetPlayerFromId(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "taxi" then
                table.insert(drivers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(drivers)
end)


RegisterServerEvent('gov-phone:server:restoreRented')
AddEventHandler('gov-phone:server:restoreRented', function(money)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    Player.Functions.AddMoney("bank", money)
end)

RegisterServerEvent('gov-phone:server:removeMoney')
AddEventHandler('gov-phone:server:removeMoney', function(type, money)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    Player.Functions.RemoveMoney(type, money)
end)

local VehiclePlate = 0
RegisterServerEvent('gov-phone:server:spawnVehicle')
AddEventHandler('gov-phone:server:spawnVehicle', function(data)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    VehiclePlate = VehiclePlate + 1

    if Config.RentelVehicles[data.model] and data.price <= Player['PlayerData']['money']['cash'] then
        data['plate'] = 'RENT-' .. VehiclePlate
        TriggerClientEvent('gov-phone:client:spawnVehicle', src, data)
        TriggerEvent('gov-phone:server:clearVehicleTrunk', data['plate'])
    else
        exports['mythic_notify']:DoHudText('error', 'You dont have enough money.')
    end
end)