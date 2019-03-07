/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/TestCryptoUtils.java-arc   1.0   Apr 09 2003 09:34:32   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/TestCryptoUtils.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import junit.framework.TestCase;

/**
 * Contains the test cases for the CryptoUtils class.
 * @author goethalo
 */
public class TestCryptoUtils extends TestCase {

    /**
     * Constructor for TestCryptoUtils.
     * @param arg0
     */
    public TestCryptoUtils(String arg0) {
        super(arg0);
    }

    /**
     * Tests the decryption of a CCB password.
     */
    public void testCcbDecrypt() {
        try {
            // DOUBLE-ENCRYPTED PASSWORD TEST
            final String encryptedKey = "ejeqkkmolpqlnmhklelfgkfnshgjiofqrhhfgqnhnnlkipjdohfmgkrdhkdnlkln";
            final String encryptedPassword = "lqmhlrfjiodehddfsoskinrsfqgheshm";
            String decryptedPassword =
                Cryptography.ccbDecrypt(encryptedKey, encryptedPassword, true);
            assertTrue(decryptedPassword.equals("thisisapassword"));

            // SINGLE-ENCRYPTED PASSWORD TEST
            final String key = "thisisakeythisisakeythisisakey";
            final String password = "qikljndrodrshhhhlprldrhfpsooljod";
            decryptedPassword =
                Cryptography.ccbDecrypt(key, password, false);
            assertTrue(decryptedPassword.equals("helloworld"));

        } catch (FIFException fe) {
            fail("Cannot decrypt password.");
        }

    }

    /**
     * Tests the encryption of a CCB password (Single encryption)
     */
    public void testCcbEncrypt() {
        try {
            // SINGLE-ENCRYPTED PASSWORD TEST
            final String key = "thisisakeythisisakeythisisakey";
            final String password = "helloworld";
            String encryptedPassword =
                Cryptography.ccbEncrypt(key, password);
            assertTrue(encryptedPassword.equals("qikljndrodrshhhhlprldrhfpsooljod"));

        } catch (FIFException fe) {
            fail("Cannot encrypt password.");
        }

    }

    /**
     * Tests the double encryption of the key.
     */
    public void testCcbDoubleEncryptKey() {
        try {
            // DOUBLE-ENCRYPT THE KEY
            final String key = "abcdefghijklmnopqrstuvwxyz";

            String encryptedKey =
                Cryptography.ccbDoubleEncryptKey(key);
            assertTrue(encryptedKey.equals("ejeqkkmolpqlnmhklelfgkfnshgjiofqrhhfgqnhnnlkipjdohfmgkrdhkdnlkln"));

        } catch (FIFException fe) {
            fail("Cannot double encrypt key.");
        }

    }

}
