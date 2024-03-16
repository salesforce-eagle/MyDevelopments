import { LightningElement } from 'lwc';
import sendOTPtoEmail from '@salesforce/apex/CTX_HelpAndSupportController.sendOTPtoEmail';

export default class Ctx_GenerateEmailOTP extends LightningElement {
    otpGenerated;
    contactEmail;
    disableGenerateOtp = false;
    otpToverify = '';
    timer='05:00';
    intervalId;
    contact;
    otpError = false;
    errorMessage = '';

    onEmailChange(event){
        this.disableGenerateOtp = false;
        this.contactEmail = event.target.value;
    }

    /*onOTPToVerifyChange(event){
        this.otpToverify = event.target.value;
        if(this.otpToverify){
            if(this.otpToverify.length === 6){
                if(this.otpGenerated === this.otpToverify){
                    this.dispatchEvent(new CustomEvent('otpverified', {detail : {contactEmail : this.contactEmail, contact : this.contact}}));
                    this.clearTimeOutInterval();
                }else{
                    //alert("failed to verify");
                    this.otpToverify = '';
                }
            }
        }
    }*/

    handleVerifyOTP(event){
        if(this.otpGenerated === event.detail){
            this.dispatchEvent(new CustomEvent('otpverified', {detail : {contactEmail : this.contactEmail, contact : this.contact}}));
            this.clearTimeOutInterval();
        }else{
            //alert("failed to verify");
            this.otpToverify = '';
            this.otpError = true;
            this.errorMessage = 'Invalid OTP';
        }
    }

    generateOTP() {
        console.log("Hi");
        const isValid = [...this.template.querySelectorAll(`[data-id="input"]`)].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(isValid){
            this.disableGenerateOtp = true;
            //this.template.querySelector(`[data-id="input"]`).className = 'slds-show';
            //this.otpGenerated = Math.floor(100000 + Math.random() * 900000);
            this.sendOTPtoEmail();
        }
    }

    sendOTPtoEmail() {
        if(this.intervalId){
            this.clearTimeOutInterval();
        }
        if(this.otpError){
            this.otpError = false;
            this.errorMessage = '';
        }
        this.calculateTimeRemainedForOTP();
        sendOTPtoEmail({contactEmail : this.contactEmail})
                .then(result => {
                    this.otpGenerated = result.returnOTP;
                    this.contact = result.availableContact;
                })
                .catch(error => {
                    console.log(error);
                })
               
    }

    get cssLetterSpacing(){
        const eWidth = this.template.querySelector(`[data-id="demoBlock"]`).clientWidth;
        let spacing = (eWidth-60)/6;
        return `letter-spacing : ${spacing}px;`;
    }

    get showSubmitOTPSection(){
        return this.disableGenerateOtp? 'slds-show' : 'slds-hide';
    }

    handleReEnterOTP (){
        this.otpError = false;
        this.errorMessage = '';
    }

    /*startTimeoutForOTP(){
        let timer = this.timer;
        let timeSplit = timer.split(":");
        let dt = new Date();
        dt.setMinutes(timeSplit[0]);
        dt.setSeconds(timeSplit[1]);

        let dt2 = new Date(dt.valueOf()-1000);

        this.timer = dt2.getMinutes() + ':' + dt2.getSeconds();
        this.intervalId = setTimeout(this.startTimeoutForOTP, 1000);
    }*/

    calculateTimeRemainedForOTP() {
        let timer = this.timer;
        let timeSplit = timer.split(":");
        let dt = new Date();
        dt.setMinutes(timeSplit[0]);
        dt.setSeconds(timeSplit[1]);
        let dt2 = new Date(dt.valueOf()-1000);

        let tempTime = dt2.toTimeString().split(" ");
        let timeCurrSplit = tempTime[0].split(":");
        this.timer = timeCurrSplit[1] + ':' + timeCurrSplit[2];

        if((timeCurrSplit[1] !== '00' || timeCurrSplit[2] !== '00')){
            this.intervalId = setTimeout(() => {
                this.calculateTimeRemainedForOTP();
            }, 1000);
        }else{
            this.otpGenerated = '';
            this.otpError = true;
            this.errorMessage = 'OTP has expired. Kindly Resend OTP and verify again.'
        }
    }

    clearTimeOutInterval() {
        window.clearTimeout(this.intervalId);
        this.timer= '05:00';
    }
}