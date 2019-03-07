/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/CCBDoubleEncrypt.java-arc   1.1   Aug 02 2004 15:26:12   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/CCBDoubleEncrypt.java-arc  $
 * 
 *    Rev 1.1   Aug 02 2004 15:26:12   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:26   goethalo
 * Initial revision.
*/
package net.arcor.fif.apps;

import net.arcor.fif.common.Cryptography;
import net.arcor.fif.common.FIFException;

/**
 * Application for encrypting a database password.
 * Given a password and key this application returns the encrypted password
 * and key.  These encrypted items can then be used in the property files.
 * <p><b>Usage:</b><p>
 * <code>java net.arcor.fif.apps.CCBDoubleEncrypt &lt;password&gt;
 * &lt;key&gt;</code>
 * @author goethalo
 */
public class CCBDoubleEncrypt {

    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println(
                "CCBDoubleEncrypt: double encrypts a password for CCB.");
            System.err.println("\nUsage: CCBDoubleEncrypt <password> <key>\n");
            System.exit(0);
        }

        String password = args[0];
        String key = args[1];

        try {
            String encryptedKey = Cryptography.ccbDoubleEncryptKey(key);
            String encryptedPassword = Cryptography.ccbEncrypt(key, password);
            System.out.println("Encrypted key: " + encryptedKey);
            System.out.println("Encrypted password: " + encryptedPassword);
        } catch (FIFException e) {
            e.printStackTrace();
        }

    }
}
