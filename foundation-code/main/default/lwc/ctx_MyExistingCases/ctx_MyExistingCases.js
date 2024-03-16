import { LightningElement,api } from 'lwc';

export default class Ctx_MyExistingCases extends LightningElement {
    @api myCases=[];

    get isEmptyCases(){
        return this.myCases.length > 0 ? false : true;
    }
}