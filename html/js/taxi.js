SetupDrivers = function(data) {
    $(".driver-list").html("");

    if (data.length > 0) {
        $.each(data, function(i, taxi){
            var element = '<div class="taxi-list" id="taxiid-'+i+'"> <div class="taxi-list-firstletter">' + (taxi.name).charAt(0).toUpperCase() + '</div> <div class="taxi-list-fullname">' + taxi.name + '</div> <div class="taxi-list-call"><i class="fas fa-phone"></i></div> </div>'
            $(".driver-list").append(element);
            $("#taxiid-"+i).data('taxiData', taxi);
        });
    } else {
        var element = '<div class="taxi-list"><div class="no-driver">Görev başında olan taksici yok.</div></div>'
        $(".driver-list").append(element);
    }
}

$(document).on('click', '.taxi-list-call', function(e){
    e.preventDefault();

    var taxiData = $(this).parent().data('taxiData');
    
    var cData = {
        number: taxiData.phone,
        name: taxiData.name
    }

    $.post('http://crp-phone_new/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: CRP.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== CRP.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (CRP.Phone.Data.AnonymousCall) {
                            CRP.Phone.Notifications.Add("fas fa-phone", "Phone", "Gizli arama başlattın!");
                        }
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        CRP.Phone.Functions.HeaderTextColor("white", 400);
                        CRP.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".taxi-app").css({"display":"none"});
                            CRP.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            CRP.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        CRP.Phone.Data.currentApplication = "phone-call";
                    } else {
                        CRP.Phone.Notifications.Add("fas fa-phone", "Phone", "Meşgulsün!");
                    }
                } else {
                    CRP.Phone.Notifications.Add("fas fa-phone", "Phone", "Aradığın numara meşgul!");
                }
            } else {
                CRP.Phone.Notifications.Add("fas fa-phone", "Phone", "Aradağın kişinin telefonu kapalı!");
            }
        } else {
            CRP.Phone.Notifications.Add("fas fa-phone", "Phone", "Kendi numaranı arayamazsın..");
        }
    });
});
