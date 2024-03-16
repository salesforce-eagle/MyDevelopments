/**
 * @description       : 
 * @author            : pramodh@warpdrivetech.in
 * @group             : 
 * @last modified on  : 01-17-2021
 * @last modified by  : pramodh@warpdrivetech.in
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   01-14-2021   pramodh@warpdrivetech.in   Initial Version
**/
public with sharing class eSignJSONGenerator {

	public class Signer_position {
		public List<Appearance> appearance;
	}

	public String reference_id;
	public String docket_title;
	public String remarks;
    public String final_copy_recipients;
	public Boolean enable_email_notification;
	public List<Documents> documents;
	public List<Signers_info> signers_info;
	public Widget_configuration widget_configuration;
    public String docket_description;
    public Boolean description_in_invitation;

	public class Signers_info {
		public String document_to_be_signed;
		public Signer_position signer_position;
		public String signer_ref_id;
		public String signer_email;
		public String signer_name;
		public String sequence;
		public String page_number;
		public String esign_type;
		public String signer_mobile;
		public String signer_remarks;
		public Signer_validation_inputs signer_validation_inputs;
		public String signature_type;
		public Boolean trigger_esign_request;
		public String access_type;
        //Added by Raksha
        public String authentication_mode;
        //End by Raksha
	}

	public class Appearance {
		public integer x1;
		public integer x2;
		public integer y1;
		public integer y2;
	}
    //Pramodh Added for New Signer Position
    public class Documents {
		public String reference_doc_id;
		public String content_type;
		public String content;
		public String signature_sequence;
		public Custom custom;
	}

	public class Signer_validation_inputs {
		public String year_of_birth;
		public String gender;
		public String name_as_per_aadhaar;
		public String last_four_digits_of_aadhaar;
	}

	public class Custom {
		public String parameter_name;
	}

	public class Widget_configuration {
		public String widget_title;
		public String background_color;
		public String button_color;
		public String button_font_color;
		public String font_family;
		public String esign_with_otp_button_text;
		public String esign_with_biometric_button_text;
		public String user_instruction;
		public String remark_field_label;
		public String usb_signature_title;
	}

	
	/*public static eSignJSONGenerator parse(String json) {
		return (eSignJSONGenerator) System.JSON.deserialize(json, eSignJSONGenerator.class);
	}*/
}