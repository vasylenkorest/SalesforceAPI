({
	init : function(cmp, event, helper) {
        
        const replayId = -1
        const empApi = cmp.find("empApi")

        const callback = function (message) { 
            console.log('message: ', JSON.parse(JSON.stringify(message.data.payload))) 
        }

        empApi.subscribe(cmp.get('v.channel'), replayId, callback).then(function(newSubscription) {})
        empApi.onError(message => console.error("Received error ", JSON.stringify(message))) 
    }
})