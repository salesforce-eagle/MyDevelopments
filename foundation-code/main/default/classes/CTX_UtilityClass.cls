public class CTX_UtilityClass {
    
    public static Boolean validateEmailAddress(String email){
        
        String 	emailRegex		= '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern emailPartten	= Pattern.compile(emailRegex);
        Matcher matchPartten	= emailPartten.matcher(email);
        
        if ( !matchPartten.matches() )
            return FALSE;
        else
            return TRUE;
    }
    
}