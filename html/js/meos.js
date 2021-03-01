var CurrentMeosPage = null;
var OpenedPerson = null;

$(document).on('click', '.meos-block', function(e){
    e.preventDefault();
    var PressedBlock = $(this).data('meosblock');
    OpenMeosPage(PressedBlock);
});

OpenMeosPage = function(page) {
    CurrentMeosPage = page;
    $(".meos-"+CurrentMeosPage+"-page").css({"display":"block"});
    $(".meos-homescreen").animate({
        left: 30+"vh"
    }, 200);
    $(".meos-tabs").animate({
        left: 0+"vh"
    }, 200, function(){
        $(".meos-tabs-footer").animate({
            bottom: 0,
        }, 200)
        if (CurrentMeosPage == "alerts") {
            $(".meos-recent-alert").removeClass("noodknop");
            $(".meos-recent-alert").css({"background-color":"#004682"}); 
        }
    });
}

SetupMeosHome = function() {
    $("#meos-app-name").html("Welkom " + QB.Phone.Data.PlayerData.charinfo.firstname + " " + QB.Phone.Data.PlayerData.charinfo.lastname);
}

MeosHomePage = function() {
    $(".meos-tabs-footer").animate({
        bottom: -5+"vh"
    }, 200);
    setTimeout(function(){
        $(".meos-homescreen").animate({
            left: 0+"vh"
        }, 200, function(){
            if (CurrentMeosPage == "alerts") {
                $(".meos-alert-new").remove();
            }
            $(".meos-"+CurrentMeosPage+"-page").css({"display":"none"});
            CurrentMeosPage = null;
            $(".person-search-results").html("");
            $(".vehicle-search-results").html("");
        });
        $(".meos-tabs").animate({
            left: -30+"vh"
        }, 200);
    }, 400);
}

$(document).on('click', '.meos-tabs-footer', function(e){
    e.preventDefault();
    MeosHomePage();
});

$(document).on('click', '.person-search-result', function(e){
    e.preventDefault();

    var ClickedPerson = this;
    var ClickedPersonId = $(this).attr('id');
    var ClickedPersonData = $("#"+ClickedPersonId).data('PersonData');

    var Gender = "Man";
    if (ClickedPersonData.gender == 1) {
        Gender = "Vrouw";
    }
    var HasLicense = "Ja";
    if (!ClickedPersonData.driverlicense) {
        HasLicense = "Nee";
    }
    var IsWarrant = "Nee";
    if (ClickedPersonData.warrant) {
        IsWarrant = "Ja";
    }
    var appartementData = {};
    if (ClickedPersonData.appartmentdata) {
        appartementData = ClickedPersonData.appartmentdata;
    }

    var OpenElement = '<div class="person-search-result-name">Naam: '+ClickedPersonData.firstname+' '+ClickedPersonData.lastname+'</div> <div class="person-search-result-bsn">BSN: '+ClickedPersonData.citizenid+'</div> <div class="person-opensplit"></div> &nbsp; <div class="person-search-result-dob">Geboortedag: '+ClickedPersonData.birthdate+'</div> <div class="person-search-result-number">Telefoon-nummer: '+ClickedPersonData.phone+'</div> <div class="person-search-result-nationality">Nationaliteit: '+ClickedPersonData.nationality+'</div> <div class="person-search-result-gender">Geslacht: '+Gender+'</div> &nbsp; <div class="person-search-result-apartment"><span id="'+ClickedPersonId+'">Appartement: '+appartementData.label+'</span> <i class="fas fa-map-marker-alt appartment-adress-location" id="'+ClickedPersonId+'"></i></div> &nbsp; <div class="person-search-result-warned">Gesignaleerd: '+IsWarrant+'</div> <div class="person-search-result-driverslicense">Rijbewijs: '+HasLicense+'</div>';

    if (OpenedPerson === null) {
        $(ClickedPerson).html(OpenElement)
        OpenedPerson = ClickedPerson;
    } else if (OpenedPerson == ClickedPerson) {
        var PreviousPersonId = $(OpenedPerson).attr('id');
        var PreviousPersonData = $("#"+PreviousPersonId).data('PersonData');
        var PreviousElement = '<div class="person-search-result-name">Name: '+PreviousPersonData.firstname+' '+PreviousPersonData.lastname+'</div> <div class="person-search-result-bsn">BSN: '+PreviousPersonData.citizenid+'</div>';
        $(ClickedPerson).html(PreviousElement)
        OpenedPerson = null;
    } else {
        var PreviousPersonId = $(OpenedPerson).attr('id');
        var PreviousPersonData = $("#"+PreviousPersonId).data('PersonData');
        var PreviousElement = '<div class="person-search-result-name">Name: '+PreviousPersonData.firstname+' '+PreviousPersonData.lastname+'</div> <div class="person-search-result-bsn">BSN: '+PreviousPersonData.citizenid+'</div>';
        $(OpenedPerson).html(PreviousElement)
        $(ClickedPerson).html(OpenElement)
        OpenedPerson = ClickedPerson;
    }
});

var OpenedHouse = null;

$(document).on('click', '.house-adress-location', function(e){
    e.preventDefault();

    var ClickedHouse = $(this).attr('id');
    var ClickedHouseData = $("#"+ClickedHouse).data('HouseData');

    $.post('http://gov-phone/SetGPSLocation', JSON.stringify({
        coords: ClickedHouseData.coords
    }))
});

$(document).on('click', '.appartment-adress-location', function(e){
    e.preventDefault();

    var ClickedPerson = $(this).attr('id');
    var ClickedPersonData = $("#"+ClickedPerson).data('PersonData');

    $.post('http://gov-phone/SetApartmentLocation', JSON.stringify({
        data: ClickedPersonData
    }));
});

$(document).on('click', '.person-search-result-apartment > span', function(e){
    e.preventDefault();

    var ClickedPerson = $(this).attr('id');
    var ClickedPersonData = $("#"+ClickedPerson).data('PersonData');

    $("#testerino").val(ClickedPersonData.appartmentdata.name)
    $("#testerino").css("display", "block")

    var copyText = document.getElementById("testerino");
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");

    QB.Phone.Notifications.Add("fas fa-university", "MEOS", "House No. copied!", "#badc58", 1750);

    $.post('http://gov-phone/SetApartmentLocation', JSON.stringify({
        data: ClickedPersonData
    }));
    $("#testerino").css("display", "none")
});

$(document).on('click', '.person-search-result-house', function(e){
    e.preventDefault();

    var ClickedHouse = this;
    var ClickedHouseId = $(this).attr('id');
    var ClickedHouseData = $("#"+ClickedHouseId).data('HouseData');

    var GarageLabel = "Nee";
    if (ClickedHouseData.garage.length > 0 ) {
        GarageLabel = "Ja";
    }

    var OpenElement = '<div class="person-search-result-name">Owner: '+ClickedHouseData.charinfo.firstname+' '+ClickedHouseData.charinfo.lastname+'</div><div class="person-search-result-bsn">House: '+ClickedHouseData.label+'</div> <div class="person-opensplit"></div> &nbsp; <div class="person-search-result-dob">Adress: '+ClickedHouseData.label+' &nbsp; <i class="fas fa-map-marker-alt house-adress-location" id="'+ClickedHouseId+'"></i></div> <div class="person-search-result-number">Tier: '+ClickedHouseData.tier+'</div> <div class="person-search-result-nationality">Garage: ' + GarageLabel + '</div>';

    if (OpenedHouse === null) {
        $(ClickedHouse).html(OpenElement)
        OpenedHouse = ClickedHouse;
    } else if (OpenedHouse == ClickedHouse) {
        var PreviousPersonId = $(OpenedHouse).attr('id');
        var PreviousPersonData = $("#"+PreviousPersonId).data('HouseData');
        var PreviousElement = '<div class="person-search-result-name">Owner: '+PreviousPersonData.charinfo.firstname+' '+PreviousPersonData.charinfo.lastname+'</div> <div class="person-search-result-bsn">House: '+PreviousPersonData.label+'</div>';
        $(ClickedHouse).html(PreviousElement)
        OpenedHouse = null;
    } else {
        var PreviousPersonId = $(OpenedHouse).attr('id');
        var PreviousPersonData = $("#"+PreviousPersonId).data('HouseData');
        var PreviousElement = '<div class="person-search-result-name">Owner: '+PreviousPersonData.charinfo.firstname+' '+PreviousPersonData.charinfo.lastname+'</div> <div class="person-search-result-bsn">House: '+PreviousPersonData.label+'</div>';
        $(OpenedHouse).html(PreviousElement)
        $(ClickedHouse).html(OpenElement)
        OpenedHouse = ClickedHouse;
    }
});

$(document).on('click', '.confirm-search-person-test', function(e){
    e.preventDefault();
    var SearchName = $(".person-search-input").val();

    if (SearchName !== "") {
        $.post('http://gov-phone/FetchSearchResults', JSON.stringify({
            input: SearchName,
        }), function(result){
            if (result != null) {
                $(".person-search-results").html("");
                $.each(result, function (i, person) {
                    var PersonElement = '<div class="person-search-result" id="person-'+i+'"><div class="person-search-result-name">Name: '+person.firstname+' '+person.lastname+'</div> <div class="person-search-result-bsn">BSN: '+person.citizenid+'</div> </div>';
                    $(".person-search-results").append(PersonElement);
                    $("#person-"+i).data("PersonData", person);
                });
            } else {
                QB.Phone.Notifications.Add("politie", "MEOS", "There are no search results!");
                $(".person-search-results").html("");
            }
        });
    } else {
        QB.Phone.Notifications.Add("politie", "MEOS", "There are no search results!");
        $(".person-search-results").html("");
    }
});

$(document).on('click', '.confirm-search-person-house', function(e){
    e.preventDefault();
    var SearchName = $(".person-search-input-house").val();

    if (SearchName !== "") {
        $.post('http://gov-phone/FetchPlayerHouses', JSON.stringify({
            input: SearchName,
        }), function(result){
            if (result != null) {
                $(".person-search-results").html("");
                $.each(result, function (i, house) {
                    var PersonElement = '<div class="person-search-result-house" id="personhouse-'+i+'"><div class="person-search-result-name">Eigenaar: '+house.charinfo.firstname+' '+house.charinfo.lastname+'</div> <div class="person-search-result-bsn">Huis: '+house.label+'</div></div>';
                    $(".person-search-results").append(PersonElement);
                    $("#personhouse-"+i).data("HouseData", house);
                });
            } else {
                QB.Phone.Notifications.Add("politie", "MEOS", "There are no search results!");
                $(".person-search-results").html("");
            }
        });
    } else {
        QB.Phone.Notifications.Add("politie", "MEOS", "There are no search results!");
        $(".person-search-results").html("");
    }
});

$(document).on('click', '.confirm-search-vehicle', function(e){
    e.preventDefault();
    var SearchName = $(".vehicle-search-input").val();
    
    if (SearchName !== "") {
        $.post('http://gov-phone/FetchVehicleResults', JSON.stringify({
            input: SearchName,
        }), function(result){
            if (result != null) {
                $(".vehicle-search-results").html("");
                $.each(result, function (i, vehicle) {
                    var APK = "Ja";
                    if (!vehicle.status) {
                        APK = "Nee";
                    }
                    var Flagged = "Nee";
                    if (vehicle.isFlagged) {
                        Flagged = "Ja";
                    }
                    
                    var VehicleElement = '<div class="vehicle-search-result"> <div class="vehicle-search-result-name">'+vehicle.label+'</div> <div class="vehicle-search-result-plate">Kenteken: '+vehicle.plate+'</div> <div class="vehicle-opensplit"></div> &nbsp; <div class="vehicle-search-result-owner">Eigenaar: '+vehicle.owner+'</div> &nbsp; <div class="vehicle-search-result-apk">APK: '+APK+'</div> <div class="vehicle-search-result-warrant">Gesignaleerd: '+Flagged+'</div> </div>'
                    $(".vehicle-search-results").append(VehicleElement);
                });
            }
        });
    } else {
        QB.Phone.Notifications.Add("politie", "MEOS", "There are no search results!");
        $(".vehicle-search-results").html("");
    }
});

$(document).on('click', '.scan-search-vehicle', function(e){
    e.preventDefault();
    $.post('http://gov-phone/FetchVehicleScan', JSON.stringify({}), function(vehicle){
        if (vehicle != null) {
            $(".vehicle-search-results").html("");
            var APK = "Ja";
            if (!vehicle.status) {
                APK = "Nee";
            }
            var Flagged = "Nee";
            if (vehicle.isFlagged) {
                Flagged = "Ja";
            }

            var VehicleElement = '<div class="vehicle-search-result"> <div class="vehicle-search-result-name">'+vehicle.label+'</div> <div class="vehicle-search-result-plate">Kenteken: '+vehicle.plate+'</div> <div class="vehicle-opensplit"></div> &nbsp; <div class="vehicle-search-result-owner">Eigenaar: '+vehicle.owner+'</div> &nbsp; <div class="vehicle-search-result-apk">APK: '+APK+'</div> <div class="vehicle-search-result-warrant">Gesignaleerd: '+Flagged+'</div> </div>'
            $(".vehicle-search-results").append(VehicleElement);
        } else {
            QB.Phone.Notifications.Add("politie", "MEOS", "No vehicle around!");
            $(".vehicle-search-results").append("");
        }
    });
});

AddPoliceAlert = function(data) {
    var randId = Math.floor((Math.random() * 10000) + 1);
    var AlertElement = '';
    if (data.alert.coords != undefined && data.alert.coords != null) {
        AlertElement = '<div class="meos-alert" id="alert-'+randId+'"> <span class="meos-alert-new" style="margin-bottom: 1vh;">NIEUW</span> <p class="meos-alert-type">Melding: '+data.alert.title+'</p> <p class="meos-alert-description">'+data.alert.description+'</p> <hr> <div class="meos-location-button">LOCATIE</div> </div>';
    } else {
        AlertElement = '<div class="meos-alert" id="alert-'+randId+'"> <span class="meos-alert-new" style="margin-bottom: 1vh;">NIEUW</span> <p class="meos-alert-type">Melding: '+data.alert.title+'</p> <p class="meos-alert-description">'+data.alert.description+'</p></div>';
    }
    $(".meos-recent-alerts").html('<div class="meos-recent-alert" id="recent-alert-'+randId+'"><span class="meos-recent-alert-title">Melding: '+data.alert.title+'</span><p class="meos-recent-alert-description">'+data.alert.description+'</p></div>');
    if (data.alert.title == "Assistentie collega") {
        $(".meos-recent-alert").css({"background-color":"#d30404"}); 
        $(".meos-recent-alert").addClass("noodknop");
    }
    $(".meos-alerts").prepend(AlertElement);
    $("#alert-"+randId).data("alertData", data.alert);
    $("#recent-alert-"+randId).data("alertData", data.alert);
}

$(document).on('click', '.meos-recent-alert', function(e){
    e.preventDefault();
    var alertData = $(this).data("alertData");

    if (alertData.coords != undefined && alertData.coords != null) {
        $.post('http://gov-phone/SetAlertWaypoint', JSON.stringify({
            alert: alertData,
        }));
    } else {
        QB.Phone.Notifications.Add("politie", "MEOS", "This message has no GPS Location!");
    }
});

$(document).on('click', '.meos-location-button', function(e){
    e.preventDefault();
    var alertData = $(this).parent().data("alertData");
    $.post('http://gov-phone/SetAlertWaypoint', JSON.stringify({
        alert: alertData,
    }));
});

$(document).on('click', '.meos-clear-alerts', function(e){
    $(".meos-alerts").html("");
    $(".meos-recent-alerts").html('<div class="meos-recent-alert"> <span class="meos-recent-alert-title">Je hebt nog geen meldingen!</span></div>');
    QB.Phone.Notifications.Add("politie", "MEOS", "All notifications have been removed!");
});