({
    executeBatch : function (cmp){
        cmp.set("v.isButtonDisabled", true); 
        var action = cmp.get("c.startBatch");
        console.log('action ' + action);
        var quoteId = cmp.get("v.recordId");
        action.setParams({
            "quoteId":quoteId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "El calculo comenzó satisfactoriamente."
                });
                toastEvent.fire();

                if (state === "SUCCESS"){
                    var interval = setInterval($A.getCallback(function () {
                        var jobStatus = cmp.get("c.getBatchJobStatus");
                        console.log('jobStatus ' + jobStatus);
                        if(jobStatus != null){
                            jobStatus.setParams({ jobID : response.getReturnValue()});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    cmp.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    var progress = cmp.get('v.progress');
                                    cmp.set('v.progress', processedPercent);
                                    cmp.set("v.isButtonDisabled", progress === 100 ? false : true);

                                    if (job.Status === "Completed" && job.NumberOfErrors === 0) {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "type": "success",
                                            "message": "El calculo finalizó satisfactoriamente."
                                        });
                                        toastEvent.fire();
                                    } else if (job.Status === "Completed" && job.NumberOfErrors > 0) {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "type": "error",
                                            "message": "Ocurrió un error. Por favor intente de nuevo o contacte al administrador."
                                        });
                                        toastEvent.fire();
                                    }
                                }
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 2000);
                     
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "Ocurrió un error. Por favor intente de nuevo o contacte al administrador."
                });
                toastEvent.fire();
                cmp.set("v.isButtonDisabled", false); 
            }
        });
        $A.enqueueAction(action);
    }
});