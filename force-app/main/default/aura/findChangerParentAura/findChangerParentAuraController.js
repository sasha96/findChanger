({

    checkExist: function (component, event, helper) {

        var action = component.get("c.createCustomMetadataRecord");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(state);
            }
            else if (state === "INCOMPLETE") {
                console.log(state);
            }
            else if (state === "ERROR") {
                console.log(state);
            }

        });

        $A.enqueueAction(action);
    }
})