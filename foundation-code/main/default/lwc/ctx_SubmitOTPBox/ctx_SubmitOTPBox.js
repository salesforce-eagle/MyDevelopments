import { LightningElement,api,track } from 'lwc';

export default class Ctx_SubmitOTPBox extends LightningElement {
    otpToverify='';
    @api cssLetterSpacing;
    @api otpError
    @api errorMessage;

    onOTPToVerifyChange(event){
        this.otpToverify = event.target.value;
        if(this.otpError){
            this.dispatchEvent(new CustomEvent('otpchange'));
        }
        if(this.otpToverify.length === 6){
            this.dispatchEvent(new CustomEvent('verifyotp', {detail : this.otpToverify}));
            this.otpToverify = '';
        }
        
    }
}