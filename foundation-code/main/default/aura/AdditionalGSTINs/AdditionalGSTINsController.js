({
	doInit : function(component, event, helper) {
          var opportunityId = component.get("v.recordId");
         console.log('Controller opportunityId '+opportunityId);
		helper.doLoad(component, event);
	},
     removeRow : function(component, event, helper){
         console.log('Remov Row');
        //var existingList = component.get("v.mainWrapper.listOfAdtnlGSTIN");
         var existingList = component.get("v.mainWrapper.listOfAdditionGSTIN");
         var btnId = event.target.id;
         var arr = btnId.split(';');
        //Adding ids of AddtnGSTIN to be deleted
         if(arr[1] != ''){
             component.get("v.listOfExistingGSTINRecordToDelete").push(arr[1]);
         }
        console.log('listOfExistingGSTINRecordToDelete '+component.get("v.listOfExistingGSTINRecordToDelete"));
        //helper.deleteLineItems(component, event);
        existingList.splice(arr[2], 1);
        //component.set("v.mainWrapper.listOfAdtnlGSTIN",existingList);
        component.set("v.mainWrapper.listOfAdditionGSTIN",existingList);
        
    },
     addRow: function(component, event, helper) {
        console.log('call add new row');
        helper.addGSTINRecord(component, event);
    },
   /* gstinValidation : function(component, event, helper) {
         console.log('gstinValidation() called ');
        console.log(event.target);
        console.log(event.target.value);
        console.log(event.target.getAttribute("value"));
         var gstin = event.target.value;
        console.log('gstin '+gstin);
        console.log('gstin length '+gstin.length);
    },*/
    onClickOfSave : function(component, event, helper){
        console.log('Save btn is clicked');
        var listOfAddtnGSTINs = component.get("v.mainWrapper.listOfAdditionGSTIN");
        console.log('listOfAddtnGSTINs ',listOfAddtnGSTINs);
        
        let mapOfQLIIdToProdName = new Map();
        let mapOfGstinQliToSumOfAmt = new Map();
        var QLIList = component.get("v.mainWrapper.listOfQLI");
        for(var i=0; i<QLIList.length; i++){
            //mapOfProdToAmount.set(QLIList[i].Product2.Name,QLIList[i].Total_Price__c);
            mapOfQLIIdToProdName.set(QLIList[i].Id, QLIList[i].Product2.Name);
        }
        console.log('mapOfQLIIdToProdName ',mapOfQLIIdToProdName);
        
        for(var i=0; i<listOfAddtnGSTINs.length ;i++){
            console.log('@i '+i);
            var QuteLineItemId = listOfAddtnGSTINs[i].QuteLineItemId;
            var GSTIN = listOfAddtnGSTINs[i].GSTIN;
            var billingAddrs1 = listOfAddtnGSTINs[i].billingAddrs1;
            var billingAddrs2 = listOfAddtnGSTINs[i].billingAddrs2;
            var city = listOfAddtnGSTINs[i].city;
            var state = listOfAddtnGSTINs[i].state;
            var pincode = listOfAddtnGSTINs[i].pincode;
            var amount = listOfAddtnGSTINs[i].amount;
            var prodName = mapOfQLIIdToProdName.get(listOfAddtnGSTINs[i].QuteLineItemId);
             var customerName = listOfAddtnGSTINs[i].nameOfTheCustomer;
            var billingPan = listOfAddtnGSTINs[i].billingPan;
            var tan = listOfAddtnGSTINs[i].tan;
            var sez = listOfAddtnGSTINs[i].sez;
            var crNum = listOfAddtnGSTINs[i].CRNumber;
            var tinNum = listOfAddtnGSTINs[i].tinNumber;
            var isGcc = component.get("v.isGcc");
   
            
            console.log('QuteLineItemId '+QuteLineItemId+' GSTIN '+GSTIN+' billingAddrs '+billingAddrs1+' amount '+amount);
            
            if(!isGcc && (QuteLineItemId == undefined ||QuteLineItemId == null || QuteLineItemId == ''||
               GSTIN == undefined || GSTIN == null || GSTIN == '' ||
              /*  customerName == undefined || customerName == null || customerName == '' ||
               billingAddrs1 == undefined || billingAddrs1 == null || billingAddrs1 == '' ||*/
               amount == undefined || amount == null || amount == '' || 
              /* city == undefined || city == null || city == '' ||
              state == undefined || state == null || state == '' ||
              pincode == undefined || pincode == null || pincode == '' ||
              billingPan == undefined || billingPan == null || billingPan == '' ||*/
              tan == undefined || tan == null || tan == '' /*||
              sez == undefined || sez == null || sez == ''*/)){
                //Please fill the mandatory fields - Product Name, GSTIN,Customer Name, Address Line 1,City,State,Pincode,Billing PAN,TAN,SEZ(Yes/No) and Amount
                helper.showToastMessage(component, event,'Please fill the mandatory fields - Product Name, GSTIN,TAN and Amount.',"Error","Error");
                return;
            }
            console.log('GSTIN.length '+GSTIN.length);
            
            console.log('@gcc '+isGcc);
            
            if(GSTIN.length != 15 && isGcc){
                helper.showToastMessage(component, event,'Not a valid VAT. Please Enter 15 characters in Billing VAT for the product - '+prodName,"Error","Error");
                return;
            }
            
            if(GSTIN.length != 15){
                helper.showToastMessage(component, event,'Not a valid GSTIN. Please Enter 15 characters in Billing GSTIN for the product - '+prodName,"Error","Error");
                return;
            }
        }
        //let mapOfProdToAmount = new Map();
       /*let mapOfQLIIdToProdName = new Map();
        let mapOfGstinQliToSumOfAmt = new Map();
        var QLIList = component.get("v.mainWrapper.listOfQLI");
        for(var i=0; i<QLIList.length; i++){
            //mapOfProdToAmount.set(QLIList[i].Product2.Name,QLIList[i].Total_Price__c);
            mapOfQLIIdToProdName.set(QLIList[i].Id, QLIList[i].Product2.Name);
        }
        console.log('mapOfQLIIdToProdName ',mapOfQLIIdToProdName);*/
        debugger;
        for(var i=0; i<listOfAddtnGSTINs.length ;i++){
            var prodName = mapOfQLIIdToProdName.get(listOfAddtnGSTINs[i].QuteLineItemId);
            console.log('prodName '+prodName);
            if(mapOfGstinQliToSumOfAmt.has(listOfAddtnGSTINs[i].QuteLineItemId)){
                var oldVal = mapOfGstinQliToSumOfAmt.get(listOfAddtnGSTINs[i].QuteLineItemId);
                 console.log('oldVal '+oldVal);
                var newVal = parseInt(oldVal) + parseInt(listOfAddtnGSTINs[i].amount);
                console.log('newVal '+newVal);
				mapOfGstinQliToSumOfAmt.set(listOfAddtnGSTINs[i].QuteLineItemId,newVal); 
            }else{
                mapOfGstinQliToSumOfAmt.set(listOfAddtnGSTINs[i].QuteLineItemId, listOfAddtnGSTINs[i].amount)
            }
        }
        console.log('mapOfGstinQliToSumOfAmt ',mapOfGstinQliToSumOfAmt);
        for(var i=0; i<QLIList.length; i++){
             var prodName = mapOfQLIIdToProdName.get(QLIList[i].Id);
            if(mapOfGstinQliToSumOfAmt.has(QLIList[i].Id)){
                var valueFromGstinTable = mapOfGstinQliToSumOfAmt.get(QLIList[i].Id);
                var valueFromQli = Math.round(QLIList[i].Total_Price__c);                                                   
                if(mapOfGstinQliToSumOfAmt.get(QLIList[i].Id) != Math.round(QLIList[i].Total_Price__c)){
                    helper.showToastMessage(component, event, prodName+' product total does not match',"Error","Error");
                    return;
                }                
            }else if(listOfAddtnGSTINs.length >0){
                console.log('ItemList'+listOfAddtnGSTINs[0]);
                helper.showToastMessage(component, event, prodName+' Product split does not exist.',"Error","Error");
                return;
            }
        }
        console.log('No prblm occured');
        //call helper to save records and delete records.
        helper.saveAdditionalGSTINRecords(component, event);
        console.log('End of save controller');
    },
    onClickOfClone : function(component, event, helper){
        console.log('Clone btn is clicked');
    }
})