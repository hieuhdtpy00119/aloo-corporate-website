package com.aloo.cms.support;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;

public final class TextEncodingSupport {

    private TextEncodingSupport() {
    }

    public static String repairUtf8Mojibake(String value) {
        if (value == null || value.isBlank()) {
            return value;
        }

        try {
            byte[] bytes = new byte[value.length()];
            for (int i = 0; i < value.length(); i++) {
                bytes[i] = (byte) value.charAt(i);
            }

            CharsetDecoder decoder = StandardCharsets.UTF_8.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT);
            CharBuffer decoded = decoder.decode(ByteBuffer.wrap(bytes));
            String repaired = decoded.toString();

            if (!repaired.equals(value) && !repaired.contains("\uFFFD")) {
                return repaired;
            }
        } catch (CharacterCodingException ignored) {
            return value;
        }

        return value;
    }
}
