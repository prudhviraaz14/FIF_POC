/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/CCBEncryptor.java-arc   1.0   Apr 09 2003 09:34:30   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/CCBEncryptor.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:30   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.util.Random;

import BlowfishJ.BinConverter;
import BlowfishJ.BlowfishECB;

/**
 * Class implementing the encryption algorithms used by the
 * AMS CCB system.
 * @author goethalo
 */
public final class CCBEncryptor extends BlowfishECB {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The encryption key.
     */
    private byte[] key = null;


    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * Generates randow key of the default size (16 bytes)
     * and instantiates the encryptor.
     * @param key   the encryption key to use.
     */
    public CCBEncryptor(byte[] key) {
        super(key);
        this.key = key;
    }

    /**
     * Constructor.
     * @param key   the encryption key to use.
     */
    public CCBEncryptor(String key) throws FIFException {
        super(key.getBytes());
        if (key == null) {
            throw new FIFException("Parameter key is null");
        }
        this.key = key.getBytes();
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Decrypts a String.
     * @param toDecrypt  the string to be decrypted
     * @return the decrypted string
     */
    public String decrypt(String toDecrypt) throws FIFException {
        try {
            if (key.length == 1) {
                return toDecrypt;
            }

            if (toDecrypt == null) {
                return null;
            }

            byte[] text = toDecrypt.getBytes();

            text = decryptForCcb(text);

            int nLen = text.length;
            long lTemp;
            for (int nI = 0; nI < nLen; nI += 8) {
                // Decrypt over a temporary 64bit block
                lTemp = byteArrayToLong(text, nI);
                lTemp = decryptBlock(lTemp);
                longToByteArray(lTemp, text, nI);
            }

            int i = 0;
            StringBuffer b = new StringBuffer((new String(text)));
            for (i = 0; i < b.length() && b.charAt(i) != '\0'; i++);
            b.setLength(i);

            return b.toString();
        } catch (IllegalArgumentException exp) {
            throw new FIFException("Cannot decrypt string");
        }
    }

    /**
     * Gets the double encryption key for Ccb
     * @return the double encryption key for Ccb
     */
    public static byte[] getCcbDoubleEncryptKey() {
        return getCcbKey();
    }

    /**
     * Generates a key of 16 bytes
     * @return the 16 byte key
     */
    public static byte[] generateKey() {
        byte[] random = new byte[8];

        Random generator = new Random();
        generator.nextBytes(random);

        return BinConverter.bytesToBinHex(random).getBytes();
    }

    /**
     * Encrypts a block for the Ccb key.
     * @param index  the index of the block to encrypt
     * @return the encrypted byte
     */
    public static byte encryptBlock(int index) {
        int block = ekHelper[index];
        long unsignedBlock =
            block < 0 ? (((long) Integer.MAX_VALUE + 1) * 2 + block) : block;
        long asciiVal = (unsignedBlock % (122 - 97)) + 97;
        byte byteVal = (byte) asciiVal;
        return byteVal;
    }

    /**
     * Encrypts a String.
     * @param toEncrypt  the string to be encrypted
     * @return the encrypted string
     */
    public String encrypt(String toEncrypt) {
        if (toEncrypt == null) {
            return null;
        }

        if (key.length == 1) {
            return toEncrypt;
        }

        int length = toEncrypt.length();
        int remainder = length - ((int) (length / 8) * 8);
        length = length + (8 - remainder);

        byte[] text = new byte[length];
        System.arraycopy(toEncrypt.getBytes(), 0, text, 0, toEncrypt.length());
        for (int i = toEncrypt.length(); i < length; i++) {
            text[i] = 0x0;
        }

        int nLen = text.length;
        long lTemp;
        for (int nI = 0; nI < nLen; nI += 8) {
            // encrypt a temporary 64bit block
            lTemp = byteArrayToLong(text, nI);
            lTemp = encryptBlock(lTemp);
            longToByteArray(lTemp, text, nI);
        }

        byte[] result = encryptForCcb(text);

        return new String(result);
    }

    /**
     * Returns the key.
     * @return the key
     */
    public String getKey() {
        byte[] tmp = (byte[]) key.clone();
        return new String(tmp);
    }

    /**
     * byteArrayToLong
     */
    private static long byteArrayToLong(byte[] a, int startPosition) {
        int lo = 0;
        for (int i = startPosition + 7; i >= startPosition + 4; i--) {
            lo = lo * 0x100;
            lo = lo + byteToUnsignedInt(a[i]);
        }

        int hi = 0;
        for (int i = startPosition + 3; i >= startPosition; i--) {
            hi = hi * 0x100;
            hi = hi + byteToUnsignedInt(a[i]);
        }

        long temp = (long) (hi * 0x100000000L + lo);

        return BinConverter.makeLong(lo, hi);
    }

    /**
     * byteToUnsignedInt
     */
    private static int byteToUnsignedInt(byte b) {
        if (b >= 0) {
            return (int) b;
        }

        return 256 - (-b);
    }

    /**
     * Decrypts a byte array for Ccb
     * @param text  the text to be decrypted
     * @return the decrypted text
     */
    private static byte[] decryptForCcb(byte[] text) throws FIFException {
        if (text == null) {
            return null;
        }

        int length = text.length;
        if (((int) (length / 2)) * 2 != length) {
            throw new FIFException("The length of array 'text' is not "
                + "dividable by 2");
        }

        byte[] result = new byte[length / 2];

        for (int k = 0, l = 0; k < length; k = k + 2, l++) {
            result[l] =
                (byte) ((text[k] - 100) | (((text[k + 1] - 100) << 4) & 0xff));
        }

        return result;
    }

    /**
     * Encrypts a byte array for Ccb.
     * @param text  the text to be encrypted
     * @return the encrypted text
     */
    private static byte[] encryptForCcb(byte[] text) {
        if (text == null) {
            return null;
        }

        byte[] result = new byte[text.length * 2];
        for (int k = 0, l = 0; k < result.length; k = k + 2, l++) {
            result[k] = (byte) (100 + (text[l] & 0x0F));
            result[k + 1] = (byte) (100 + ((text[l] & 0xF0) >> 4));

        }

        return result;
    }

    /**
     * Generates the Ccb key.
     * @return the ccb key
     */
    private static byte[] getCcbKey() {
        byte[] buffer = new byte[18 * 4];

        for (int i = 0; i < 18; i++) {
            int index = i * 4;
            buffer[index + 0] = encryptBlock((index + 0) % 16);
            buffer[index + 1] = encryptBlock((index + 1) % 16);
            buffer[index + 2] = encryptBlock((index + 2) % 16);
            if (((index + 3) % 16) != 15) {
                buffer[index + 3] = encryptBlock((index + 3) % 16);
            } else {
                buffer[index + 3] = encryptBlock(0);
            }
        }

        return buffer;
    }

    /**
     * Converts a long to a byte array.
     */
    private static void longToByteArray(
        long lValue,
        byte[] buffer,
        int nStartIndex) {
        buffer[nStartIndex + 3] = (byte) (lValue >>> 56);
        buffer[nStartIndex + 2] = (byte) ((lValue >>> 48) & 0x0ff);
        buffer[nStartIndex + 1] = (byte) ((lValue >>> 40) & 0x0ff);
        buffer[nStartIndex + 0] = (byte) ((lValue >>> 32) & 0x0ff);
        buffer[nStartIndex + 7] = (byte) ((lValue >>> 24) & 0x0ff);
        buffer[nStartIndex + 6] = (byte) ((lValue >>> 16) & 0x0ff);
        buffer[nStartIndex + 5] = (byte) ((lValue >>> 8) & 0x0ff);
        buffer[nStartIndex + 4] = (byte) lValue;
    }

    /**
     * Blowfish encryptkey helper.
     */
    private final static int ekHelper[] =
        {
            0x0000000F,
            0x66CA593E,
            0x82430E88,
            0x8CEE8619,
            0x456F9FB4,
            0x7D84A5C3,
            0x3B8B5EBE,
            0xE06F75D8,
            0x85C12073,
            0x401A449F,
            0x56C16AA6,
            0x4ED3AA62,
            0xB45A5ECE,
            0x002F0538,
            0x86C52E7F,
            0x461E4183 };

}
