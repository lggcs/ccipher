#!/bin/sh
# A collection of classical ciphers in pure POSIX.
# License: CC0 1.0 Universal

# Function to perform Caesar Cipher encryption/decryption
caesar_cipher() {
    caesar_text="$1"
    caesar_shift="$2"
    caesar_mode="$3"
    caesar_result=""
    caesar_char=""
    caesar_ascii=""

    if [ "$caesar_shift" -lt 0 ] || [ "$caesar_shift" -ge 26 ]; then
        echo "Error: Shift value must be between 0 and 25."
        return 1
    fi

    if [ "$caesar_mode" = "decrypt" ]; then
        caesar_shift=$((26 - caesar_shift))
    fi

    while [ -n "$caesar_text" ]; do
        caesar_char="${caesar_text%"${caesar_text#?}"}"
        caesar_text="${caesar_text#?}"
        caesar_ascii=$(printf "%d" "'$caesar_char")

        if [ "$caesar_char" = " " ]; then
            caesar_result="$caesar_result$caesar_char"
        else
            if [ "$caesar_ascii" -ge 65 ] && [ "$caesar_ascii" -le 90 ]; then
                caesar_ascii=$(( (caesar_ascii - 65 + caesar_shift) % 26 + 65 ))
            elif [ "$caesar_ascii" -ge 97 ] && [ "$caesar_ascii" -le 122 ]; then
                caesar_ascii=$(( (caesar_ascii - 97 + caesar_shift) % 26 + 97 ))
            fi
            caesar_result="$caesar_result$(printf "\\$(printf "%o" $caesar_ascii)")"
        fi
    done

    echo "$caesar_result"
}

# Function to perform Affine Cipher encryption/decryption
affine_cipher() {
    affine_text="$1"
    affine_a="$2"
    affine_b="$3"
    affine_mode="$4"
    affine_result=""
    affine_char=""
    affine_ascii=""
    affine_inv_a=0

    # Check if a and b are within valid range
    if [ "$affine_a" -le 0 ] || [ "$affine_a" -ge 26 ] || [ "$affine_b" -lt 0 ] || [ "$affine_b" -ge 26 ]; then
        echo "Error: 'a' must be between 1 and 25, 'b' must be between 0 and 25."
        return 1
    fi

    if [ "$affine_mode" = "decrypt" ]; then
        affine_inv_a=$(mod_inverse "$affine_a" 26)
        if [ "$?" -ne 0 ]; then
            echo "Error: 'a' has no modular inverse."
            return 1
        fi
    fi

    while [ -n "$affine_text" ]; do
        affine_char="${affine_text%"${affine_text#?}"}"
        affine_text="${affine_text#?}"
        affine_ascii=$(printf "%d" "'$affine_char")

        if [ "$affine_char" = " " ]; then
            affine_result="$affine_result$affine_char"
        else
            if [ "$affine_ascii" -ge 65 ] && [ "$affine_ascii" -le 90 ]; then
                if [ "$affine_mode" = "encrypt" ]; then
                    affine_ascii=$(( (affine_a * (affine_ascii - 65) + affine_b) % 26 + 65 ))
                else
                    affine_ascii=$(( (affine_inv_a * (affine_ascii - 65 - affine_b + 26)) % 26 + 65 ))
                fi
            elif [ "$affine_ascii" -ge 97 ] && [ "$affine_ascii" -le 122 ]; then
                if [ "$affine_mode" = "encrypt" ]; then
                    affine_ascii=$(( (affine_a * (affine_ascii - 97) + affine_b) % 26 + 97 ))
                else
                    affine_ascii=$(( (affine_inv_a * (affine_ascii - 97 - affine_b + 26)) % 26 + 97 ))
                fi
            fi
            affine_result="$affine_result$(printf "\\$(printf "%o" $affine_ascii)")"
        fi
    done

    echo "$affine_result"
}

# Function to perform Rot13 encryption/decryption
rot13() {
    rot13_text="$1"
    rot13_result=""
    rot13_char=""
    rot13_ascii=""

    while [ -n "$rot13_text" ]; do
        rot13_char="${rot13_text%"${rot13_text#?}"}"
        rot13_text="${rot13_text#?}"
        rot13_ascii=$(printf "%d" "'$rot13_char")

        if [ "$rot13_char" = " " ]; then
            rot13_result="$rot13_result$rot13_char"
        else
            if [ "$rot13_ascii" -ge 65 ] && [ "$rot13_ascii" -le 90 ]; then
                rot13_ascii=$(( (rot13_ascii - 65 + 13) % 26 + 65 ))
            elif [ "$rot13_ascii" -ge 97 ] && [ "$rot13_ascii" -le 122 ]; then
                rot13_ascii=$(( (rot13_ascii - 97 + 13) % 26 + 97 ))
            fi
            rot13_result="$rot13_result$(printf "\\$(printf "%o" $rot13_ascii)")"
        fi
    done

    echo "$rot13_result"
}

# Function to perform Atbash encryption/decryption
atbash() {
    atbash_text="$1"
    atbash_result=""
    atbash_char=""
    atbash_ascii=""

    while [ -n "$atbash_text" ]; do
        atbash_char="${atbash_text%"${atbash_text#?}"}"
        atbash_text="${atbash_text#?}"
        atbash_ascii=$(printf "%d" "'$atbash_char")

        if [ "$atbash_char" = " " ]; then
            atbash_result="$atbash_result$atbash_char"
        else
            if [ "$atbash_ascii" -ge 65 ] && [ "$atbash_ascii" -le 90 ]; then
                atbash_ascii=$(( 155 - atbash_ascii ))
            elif [ "$atbash_ascii" -ge 97 ] && [ "$atbash_ascii" -le 122 ]; then
                atbash_ascii=$(( 219 - atbash_ascii ))
            fi
            atbash_result="$atbash_result$(printf "\\$(printf "%o" $atbash_ascii)")"
        fi
    done

    echo "$atbash_result"
}

# Function to calculate modular inverse
mod_inverse() {
    modinv_a="$1"
    modinv_m="$2"
    modinv_t=0
    modinv_new_t=1
    modinv_r="$modinv_m"
    modinv_new_r="$modinv_a"
    modinv_quotient=""
    modinv_temp=""

    while [ "$modinv_new_r" -ne 0 ]; do
        modinv_quotient=$(( modinv_r / modinv_new_r ))
        modinv_temp=$modinv_new_t
        modinv_new_t=$(( modinv_t - modinv_quotient * modinv_new_t ))
        modinv_t="$modinv_temp"
        modinv_temp=$modinv_new_r
        modinv_new_r=$(( modinv_r - modinv_quotient * modinv_new_r ))
        modinv_r="$modinv_temp"
    done

    if [ "$modinv_r" -gt 1 ]; then
        echo "No inverse"
        return 1
    fi

    if [ "$modinv_t" -lt 0 ]; then
        modinv_t=$(( modinv_t + modinv_m ))
    fi

    echo "$modinv_t"
}


generate_playfair_matrix() {
    pf_key=$(echo "$1" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -d '[:space:]')
    pf_alphabet="ABCDEFGHIKLMNOPQRSTUVWXYZ"
    pf_matrix=""
    pf_used=""

    for pf_char in $(echo "$pf_key" | grep -o .); do
        if ! echo "$pf_used" | grep -q "$pf_char"; then
            pf_used="$pf_used$pf_char"
            pf_matrix="$pf_matrix$pf_char"
        fi
    done

    for pf_char in $(echo "$pf_alphabet" | grep -o .); do
        if ! echo "$pf_used" | grep -q "$pf_char"; then
            pf_matrix="$pf_matrix$pf_char"
        fi
    done

    echo "$pf_matrix"
}

prepare_playfair_text() {
    pf_text=$(echo "$1" | tr -d '[:space:]' | tr 'a-z' 'A-Z' | tr 'J' 'I')
    pf_prepared=""
    pf_char1=""
    pf_char2=""

    while [ -n "$pf_text" ]; do
        pf_char1=$(echo "$pf_text" | cut -c 1)
        pf_text=$(echo "$pf_text" | cut -c 2-)
        pf_char2=$(echo "$pf_text" | cut -c 1)

        if [ -z "$pf_char2" ] || [ "$pf_char1" = "$pf_char2" ]; then
            pf_char2="X"
        else
            pf_text=$(echo "$pf_text" | cut -c 2-)
        fi

        pf_prepared="$pf_prepared$pf_char1$pf_char2"
    done

    if [ $((${#pf_prepared} % 2)) -ne 0 ]; then
        pf_prepared="${pf_prepared}X"
    fi

    echo "$pf_prepared"
}

playfair_cipher() {
    pf_text=$(prepare_playfair_text "$1")
    pf_key_matrix=$(generate_playfair_matrix "$2")
    pf_mode="$3"
    pf_result=""
    pf_pos1=""
    pf_pos2=""
    pf_row1=""
    pf_col1=""
    pf_row2=""
    pf_col2=""
    pf_char1=""
    pf_char2=""
    pf_i=""
    pf_tmp=""

    for pf_i in $(seq 1 2 ${#pf_text}); do
        pf_char1=$(echo "$pf_text" | cut -c $pf_i)
        pf_char2=$(echo "$pf_text" | cut -c $((pf_i+1)))

        pf_pos1=$(expr index "$pf_key_matrix" "$pf_char1")
        pf_pos2=$(expr index "$pf_key_matrix" "$pf_char2")

        pf_row1=$(( (pf_pos1 - 1) / 5 ))
        pf_col1=$(( (pf_pos1 - 1) % 5 ))
        pf_row2=$(( (pf_pos2 - 1) / 5 ))
        pf_col2=$(( (pf_pos2 - 1) % 5 ))

        if [ "$pf_row1" -eq "$pf_row2" ]; then
            if [ "$pf_mode" = "encrypt" ]; then
                pf_col1=$(( (pf_col1 + 1) % 5 ))
                pf_col2=$(( (pf_col2 + 1) % 5 ))
            else
                pf_col1=$(( (pf_col1 + 4) % 5 ))
                pf_col2=$(( (pf_col2 + 4) % 5 ))
            fi
        elif [ "$pf_col1" -eq "$pf_col2" ]; then
            if [ "$pf_mode" = "encrypt" ]; then
                pf_row1=$(( (pf_row1 + 1) % 5 ))
                pf_row2=$(( (pf_row2 + 1) % 5 ))
            else
                pf_row1=$(( (pf_row1 + 4) % 5 ))
                pf_row2=$(( (pf_row2 + 4) % 5 ))
            fi
        else
            pf_tmp="$pf_col1"
            pf_col1="$pf_col2"
            pf_col2="$pf_tmp"
        fi

        pf_result="$pf_result$(echo "$pf_key_matrix" | cut -c $((pf_row1 * 5 + pf_col1 + 1)))"
        pf_result="$pf_result$(echo "$pf_key_matrix" | cut -c $((pf_row2 * 5 + pf_col2 + 1)))"
    done

    echo "$pf_result"
}

# Function to generate the repeated key for Vigenère cipher
generate_repeated_key() {
    repkey_text="$1"
    repkey_key="$2"
    repkey_result=""
    repkey_i=""

    for repkey_i in $(seq 0 $((${#repkey_text} - 1))); do
        repkey_result="$repkey_result$(echo "$repkey_key" | cut -c $((repkey_i % ${#repkey_key} + 1)))"
    done

    echo "$repkey_result"
}

# Function to encrypt/decrypt using Vigenère cipher
vigenere_cipher() {
    vig_text="$1"
    vig_key="$2"
    vig_mode="$3"
    vig_repeated_key=""
    vig_result=""
    vig_char_text=""
    vig_char_key=""
    vig_ascii_text=""
    vig_ascii_key=""
    vig_shift=""
    vig_i=""

    vig_text=$(echo "$vig_text" | tr 'a-z' 'A-Z' | tr -d ' ')
    vig_key=$(echo "$vig_key" | tr 'a-z' 'A-Z')

    vig_repeated_key=$(generate_repeated_key "$vig_text" "$vig_key")

    for vig_i in $(seq 1 ${#vig_text}); do
        vig_char_text=$(echo "$vig_text" | cut -c $vig_i)
        vig_char_key=$(echo "$vig_repeated_key" | cut -c $vig_i)
        vig_ascii_text=$(printf "%d" "'$vig_char_text")
        vig_ascii_key=$(printf "%d" "'$vig_char_key")

        if [ "$vig_mode" = "encrypt" ]; then
            vig_shift=$(( (vig_ascii_text - 65 + vig_ascii_key - 65) % 26 + 65 ))
        else
            vig_shift=$(( (vig_ascii_text - vig_ascii_key + 26) % 26 + 65 ))
        fi

        vig_result="$vig_result$(printf "\\$(printf "%o" $vig_shift)")"
    done

    echo "$vig_result"
}

# Function to encrypt/decrypt using Beaufort cipher
beaufort_cipher() {
    beau_text="$1"
    beau_key="$2"
    beau_repeated_key=""
    beau_result=""
    beau_char_text=""
    beau_char_key=""
    beau_ascii_text=""
    beau_ascii_key=""
    beau_shift=""
    beau_i=""

    beau_text=$(echo "$beau_text" | tr 'a-z' 'A-Z' | tr -d ' ')
    beau_key=$(echo "$beau_key" | tr 'a-z' 'A-Z')

    beau_repeated_key=$(generate_repeated_key "$beau_text" "$beau_key")

    for beau_i in $(seq 1 ${#beau_text}); do
        beau_char_text=$(echo "$beau_text" | cut -c $beau_i)
        beau_char_key=$(echo "$beau_repeated_key" | cut -c $beau_i)
        beau_ascii_text=$(printf "%d" "'$beau_char_text")
        beau_ascii_key=$(printf "%d" "'$beau_char_key")

        # Calculate shift for Beaufort cipher (key - plaintext)
        beau_shift=$(( (beau_ascii_key - beau_ascii_text + 26) % 26 + 65 ))

        beau_result="$beau_result$(printf "\\$(printf "%o" $beau_shift)")"
    done

    echo "$beau_result"
}

# Function to encrypt/decrypt using the Trithemius cipher
trithemius_cipher() {
    trit_text="$1"
    trit_mode="$2"
    trit_result=""
    trit_char_text=""
    trit_ascii_text=""
    trit_shift=""
    trit_i=""

    # Prepare the input text: uppercase and remove spaces
    trit_text=$(echo "$trit_text" | tr 'a-z' 'A-Z' | tr -d ' ')

    for trit_i in $(seq 1 ${#trit_text}); do
        trit_char_text=$(echo "$trit_text" | cut -c $trit_i)
        trit_ascii_text=$(printf "%d" "'$trit_char_text")

        if [ "$trit_mode" = "encrypt" ]; then
            # Encrypt: Add the progressive key (i-1)
            trit_shift=$(( (trit_ascii_text - 65 + (trit_i - 1)) % 26 + 65 ))
        else
            # Decrypt: Subtract the progressive key (i-1)
            trit_shift=$(( (trit_ascii_text - 65 - (trit_i - 1) + 26) % 26 + 65 ))
        fi

        trit_result="$trit_result$(printf "\\$(printf "%o" $trit_shift)")"
    done

    echo "$trit_result"
}


railfence_cipher() {
    rf_text="$1"
    rf_key="$2"
    rf_mode="$3" # "encrypt" or "decrypt"
    rf_result=""

    # Check if the key is numeric
    case "$rf_key" in
        ''|*[!0-9]*) echo "Error: Key must be a numeric value."; return 1 ;;
    esac

    # Get the length of the text
    rf_len=${#rf_text}

    # Check if the key is less than 1
    if [ "$rf_key" -lt 1 ]; then
        echo "Error: Key must be at least 1."
        return 1
    fi

    # Check if the key is greater than the length of the text
    if [ "$rf_key" -gt "$rf_len" ]; then
        echo "Error: Key must not exceed the length of the text ($rf_len)."
        return 1
    fi

    # If key is 1, return the text as is
    if [ "$rf_key" -eq 1 ]; then
        echo "$rf_text"
        return
    fi

    if [ "$rf_mode" = "encrypt" ]; then
        # Encrypt the text
        rf_result=$(echo "$rf_text" | awk -v key=$rf_key '
        {
            len = length($0);
            rows = key;
            zigzag = 2 * (rows - 1);

            # Initialize arrays to hold each row
            for (r = 1; r <= rows; r++) {
                row_texts[r] = "";
            }

            # Distribute characters to their respective rows
            row = 1;
            direction = 1;
            for (i = 1; i <= len; i++) {
                row_texts[row] = row_texts[row] substr($0, i, 1);
                if (row == 1) {
                    direction = 1;
                } else if (row == rows) {
                    direction = -1;
                }
                row += direction;
            }

            # Concatenate rows to form the result
            result = "";
            for (r = 1; r <= rows; r++) {
                result = result row_texts[r];
            }
            print result;
        }')

    elif [ "$rf_mode" = "decrypt" ]; then
        # Decrypt the text
        rf_result=$(echo "$rf_text" | awk -v key=$rf_key '
        {
            len = length($0);
            rows = key;
            zigzag = 2 * (rows - 1);

            # Calculate the zigzag positions for each character
            row = 1;
            direction = 1;
            for (i = 1; i <= len; i++) {
                positions[i] = row;
                if (row == 1) {
                    direction = 1;
                } else if (row == rows) {
                    direction = -1;
                }
                row += direction;
            }

            # Calculate the length of each row
            row_lengths[row] = 0;
            for (i = 1; i <= len; i++) {
                row_lengths[positions[i]]++;
            }

            # Allocate characters to each row
            row_texts[row] = "";
            idx = 1;
            for (r = 1; r <= rows; r++) {
                for (j = 1; j <= row_lengths[r]; j++) {
                    row_texts[r] = row_texts[r] substr($0, idx, 1);
                    idx++;
                }
            }

            # Reconstruct the original text
            result = "";
            row = 1;
            direction = 1;
            for (i = 1; i <= len; i++) {
                result = result substr(row_texts[row], 1, 1);
                row_texts[row] = substr(row_texts[row], 2);
                if (row == 1) {
                    direction = 1;
                } else if (row == rows) {
                    direction = -1;
                }
                row += direction;
            }
            print result;
        }')
    else
        echo "Error: Mode must be 'encrypt' or 'decrypt'."
        return 1
    fi

    echo "$rf_result"
}

nihilist_cipher() {
    nih_text="$1"
    nih_key="$2"
    nih_mode="$3"
    nih_square="ABCDEFGHIKLMNOPQRSTUVWXYZ" # Polybius square (I/J combined)
    nih_result=""
    nih_key_index=1
    nih_num_text=""
    nih_num_key=""
    nih_char_text=""
    nih_char_key=""
    nih_cipher_value=""
    nih_row=""
    nih_col=""
    nih_index=""

    # Prepare the key: uppercase, combine I/J
    nih_key=$(printf "%s" "$nih_key" | tr 'a-z' 'A-Z' | tr 'J' 'I')

    # Prepare the ciphertext for decryption (no modification needed for numbers)
    if [ "$nih_mode" = "encrypt" ]; then
        nih_text=$(printf "%s" "$nih_text" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -d ' ')
    fi

    while [ -n "$nih_text" ]; do
        # Extract the first block (characters for encryption or numbers for decryption)
        if [ "$nih_mode" = "encrypt" ]; then
            nih_char_text=${nih_text%${nih_text#?}}
            nih_text=${nih_text#?}
        else
            # Extract numeric pairs (ciphertext)
            nih_char_text=${nih_text%% *}
            nih_text=${nih_text#"$nih_char_text"}
            nih_text=$(printf "%s" "$nih_text" | sed 's/^ *//') # Trim leading spaces
        fi

        if [ "$nih_mode" = "encrypt" ]; then
            # Find the numeric coordinate of the plaintext character in the Polybius square
            nih_num_text=$(expr index "$nih_square" "$nih_char_text")
            if [ $nih_num_text -eq 0 ]; then
                echo "Error: Character '$nih_char_text' not found in Polybius square"
                return 1
            fi
            nih_num_text=$(( (nih_num_text - 1) / 5 * 10 + (nih_num_text - 1) % 5 + 11 ))
        else
            # Use numeric ciphertext directly during decryption
            nih_num_text=$nih_char_text
        fi

        # Get the corresponding key character
        nih_char_key=$(printf "%s" "$nih_key" | cut -c "$nih_key_index")
        nih_key_index=$(( (nih_key_index % ${#nih_key}) + 1 ))

        # Find the numeric value for the key character in the Polybius square
        nih_num_key=$(expr index "$nih_square" "$nih_char_key")
        if [ $nih_num_key -eq 0 ]; then
            echo "Error: Key character '$nih_char_key' not found in Polybius square"
            return 1
        fi
        nih_num_key=$(( (nih_num_key - 1) / 5 * 10 + (nih_num_key - 1) % 5 + 11 ))

        if [ "$nih_mode" = "encrypt" ]; then
            nih_cipher_value=$((nih_num_text + nih_num_key))
            nih_result="$nih_result$nih_cipher_value "
        else
            # Decrypt: Adjust for negative values by adding 100 (mod 100 logic)
            nih_cipher_value=$((nih_num_text - nih_num_key))
            if [ "$nih_cipher_value" -lt 0 ]; then
                nih_cipher_value=$((nih_cipher_value + 100))
            fi

            # Validate that cipher value corresponds to a valid Polybius coordinate
            nih_row=$((nih_cipher_value / 10 - 1))
            nih_col=$((nih_cipher_value % 10 - 1))
            nih_index=$((nih_row * 5 + nih_col))
            if [ $nih_row -lt 0 ] || [ $nih_col -lt 0 ] || [ $nih_index -ge ${#nih_square} ]; then
                echo "Error: Decryption failed, invalid cipher value '$nih_cipher_value'"
                return 1
            fi

            # Convert cipher value back to a character
            nih_result="$nih_result$(printf "%s" "$nih_square" | cut -c $((nih_index + 1)))"
        fi
    done

    # Output the result
    printf "%s\n" "$nih_result" | sed 's/ $//'
}

# Helper to find Greatest Common Divisor
gcd() {
    gcd_a="$1"
    gcd_b="$2"
    while [ "$gcd_b" -ne 0 ]; do
        gcd_temp=$gcd_b
        gcd_b=$((gcd_a % gcd_b))
        gcd_a=$gcd_temp
    done
    echo "$gcd_a"
}




hill_cipher() {
    # Input: mode (encrypt/decrypt), key, text
    hill_text="$1"
    hill_key="$2"
    hill_mode="$3"

    # Extract key values
    hill_k1=$(echo "$hill_key" | cut -d' ' -f1)
    hill_k2=$(echo "$hill_key" | cut -d' ' -f2)
    hill_k3=$(echo "$hill_key" | cut -d' ' -f3)
    hill_k4=$(echo "$hill_key" | cut -d' ' -f4)

    # Validate the determinant of the key matrix
    hill_det=$((hill_k1 * hill_k4 - hill_k2 * hill_k3))
    hill_det=$((hill_det % 26))
    [ "$hill_det" -lt 0 ] && hill_det=$((hill_det + 26))

    # Check if the determinant is coprime with 26
    hill_gcd=$(gcd "$hill_det" 26)  # Function to calculate the GCD
    if [ "$hill_gcd" -ne 1 ]; then
        echo "Error: Invalid key. The determinant ($hill_det) is not coprime with 26." >&2
        return 1
    fi

    hill_det_inv=$(mod_inverse "$hill_det" 26)
    if [ -z "$hill_det_inv" ]; then
        echo "Error: The determinant ($hill_det) is not invertible modulo 26. Decryption is not possible with this key." >&2
        return 1
    fi

    # Adjust key matrix for decryption
    if [ "$hill_mode" = "decrypt" ]; then
        hill_tmp_k1=$hill_k1; hill_tmp_k2=$hill_k2; hill_tmp_k3=$hill_k3; hill_tmp_k4=$hill_k4
        hill_k1=$((hill_det_inv * hill_tmp_k4 % 26))
        hill_k2=$((-hill_det_inv * hill_tmp_k2 % 26))
        hill_k3=$((-hill_det_inv * hill_tmp_k3 % 26))
        hill_k4=$((hill_det_inv * hill_tmp_k1 % 26))
        [ "$hill_k1" -lt 0 ] && hill_k1=$((hill_k1 + 26))
        [ "$hill_k2" -lt 0 ] && hill_k2=$((hill_k2 + 26))
        [ "$hill_k3" -lt 0 ] && hill_k3=$((hill_k3 + 26))
        [ "$hill_k4" -lt 0 ] && hill_k4=$((hill_k4 + 26))
    fi

    # Prepare text: Remove spaces and pad with 'X' if necessary
    hill_clean_text=$(echo "$hill_text" | tr -d '[:space:]' | tr -cd '[:alpha:]' | tr '[:lower:]' '[:upper:]')
    [ "$hill_mode" = "encrypt" ] && [ $(( ${#hill_clean_text} % 2 )) -ne 0 ] && hill_clean_text="${hill_clean_text}X"

    # Initialize result
    hill_result=""

    # Process text in pairs of characters
    while [ -n "$hill_clean_text" ]; do
        hill_char1=$(echo "$hill_clean_text" | cut -c1)
        hill_char2=$(echo "$hill_clean_text" | cut -c2)

        hill_t1=$(( $(printf '%d' "'$hill_char1") - 65 ))
        hill_t2=$(( $(printf '%d' "'$hill_char2") - 65 ))

        hill_res1=$(( (hill_k1 * hill_t1 + hill_k2 * hill_t2) % 26 ))
        hill_res2=$(( (hill_k3 * hill_t1 + hill_k4 * hill_t2) % 26 ))

        [ "$hill_res1" -lt 0 ] && hill_res1=$((hill_res1 + 26))
        [ "$hill_res2" -lt 0 ] && hill_res2=$((hill_res2 + 26))

        hill_e1=$(printf "\\$(printf '%03o' $((hill_res1 + 65)))")
        hill_e2=$(printf "\\$(printf '%03o' $((hill_res2 + 65)))")

        hill_result="$hill_result$hill_e1$hill_e2"
        hill_clean_text=$(echo "$hill_clean_text" | cut -c3-)
    done

    echo "$hill_result"
}


generate_and_print_keysquare() {
    # Create the characters A-Z and 0-9
    adfgvx_chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    # Shuffle the characters using `awk` to ensure randomness
    adfgvx_temp_keysquare=$(printf "%s\n" $(echo "$adfgvx_chars" | fold -w1 | awk 'BEGIN {srand()} {a[NR]=$1}
        END {for (i=NR; i>=1; i--) {j=int(rand()*i)+1; t=a[i]; a[i]=a[j]; a[j]=t}
        for (i=1; i<=NR; i++) printf("%s", a[i])}'))

    # Print the key square as a single line
    if [ "$adfgvx_mode" = "encrypt" ]; then
    printf "Here's a generated ADFGVX Key Square: %s\n" "$adfgvx_temp_keysquare"
    fi
}

adfgvx_cipher() {
    adfgvx_text="$1"
    adfgvx_key="$2"
    adfgvx_mode="$3"
    adfgvx_keysquare="$4"
    adfgvx_clean_text=""
    adfgvx_result=""
    adfgvx_length=""
    adfgvx_i=""
    adfgvx_char=""
    adfgvx_pos=""
    adfgvx_row=""
    adfgvx_col=""
    adfgvx_num_cols=""
    adfgvx_column_order=""
    adfgvx_transposed_result=""
    adfgvx_reverse_result=""
    adfgvx_num_rows=""
    adfgvx_pair=""
    adfgvx_symbol1=""
    adfgvx_symbol2=""
    adfgvx_index=""
    adfgvx_mapped_char=""
    adfgvx_symbols="ADFGVX"

    # Clean and validate keysquare
    adfgvx_keysquare=$(echo "$adfgvx_keysquare" | tr -d '[:space:]' | tr -d '[:cntrl:]' | tr 'a-z' 'A-Z')
    if [ "$(echo -n "$adfgvx_keysquare" | wc -c)" -ne 36 ]; then
        echo "Error: Keysquare must be exactly 36 characters long." >&2
        generate_and_print_keysquare
        return 1
    fi

    # Clean and prepare input text
    adfgvx_clean_text=$(echo "$adfgvx_text" | tr -d '[:space:]' | tr -d '[:cntrl:]' | tr 'a-z' 'A-Z')

    # Normalize key
    adfgvx_key=$(echo "$adfgvx_key" | tr 'a-z' 'A-Z')  # Consistent normalization

    if [ "$adfgvx_mode" = "encrypt" ]; then
        # Encryption Logic
        adfgvx_result=""
        adfgvx_length=$(echo -n "$adfgvx_clean_text" | wc -c)

        adfgvx_i=1
        while [ $adfgvx_i -le "$adfgvx_length" ]; do
            adfgvx_char=$(echo "$adfgvx_clean_text" | cut -c $adfgvx_i)
            adfgvx_pos=$(awk -v c="$adfgvx_char" '
                BEGIN {
                    keysquare = "'"$adfgvx_keysquare"'"
                    for (i = 1; i <= length(keysquare); i++) {
                        if (substr(keysquare, i, 1) == c) {
                            row = int((i - 1) / 6)
                            col = (i - 1) % 6
                            printf("%d %d\n", row, col)
                            exit
                        }
                    }
                }')
            adfgvx_row=$(echo "$adfgvx_pos" | cut -d' ' -f1)
            adfgvx_col=$(echo "$adfgvx_pos" | cut -d' ' -f2)

            adfgvx_result="${adfgvx_result}$(echo "$adfgvx_symbols" | cut -c $((adfgvx_row + 1)))$(echo "$adfgvx_symbols" | cut -c $((adfgvx_col + 1)))"
            adfgvx_i=$((adfgvx_i + 1))
        done

        # Transposition Phase
        adfgvx_num_cols=$(echo -n "$adfgvx_key" | wc -c)
        adfgvx_column_order=$(echo "$adfgvx_key" | fold -w1 | nl -nln | sort -k2 | awk '{print $1}')

        adfgvx_transposed_result=""
        for adfgvx_col in $adfgvx_column_order; do
            adfgvx_pos=$((adfgvx_col - 1))
            while [ $adfgvx_pos -lt ${#adfgvx_result} ]; do
                adfgvx_transposed_result="${adfgvx_transposed_result}$(echo "$adfgvx_result" | cut -c $((adfgvx_pos + 1)))"
                adfgvx_pos=$((adfgvx_pos + adfgvx_num_cols))
            done
        done

        echo "$adfgvx_transposed_result"
elif [ "$adfgvx_mode" = "decrypt" ]; then
    # Validate ciphertext length and calculate dimensions
    adfgvx_length=$(printf "%s" "$adfgvx_clean_text" | wc -c)

    adfgvx_num_cols=$(printf "%s" "$adfgvx_key" | wc -c)
    adfgvx_num_rows=$(( (adfgvx_length + adfgvx_num_cols - 1) / adfgvx_num_cols ))

    # Generate column order based on the key
    adfgvx_column_order=$(printf "%s" "$adfgvx_key" | fold -w1 | nl -nln | sort -k2 | awk '{print $1}')

    # Reverse transpose ciphertext using awk
    adfgvx_reverse_result=$(printf "%s" "$adfgvx_clean_text" | awk -v order="$adfgvx_column_order" -v num_cols="$adfgvx_num_cols" -v text_length="$adfgvx_length" '
    BEGIN {
        split(order, col_order, " ")
        column_index = 1
        start_index = 1
        extra_chars = text_length % num_cols
    }

    {
        # Determine correct column lengths
        for (i = 1; i <= num_cols; i++) {
            col_lengths[i] = int(text_length / num_cols)
            if (i <= extra_chars) {
                col_lengths[i] += 1
            }
        }

        # Extract columns based on calculated lengths
        for (i = 1; i <= num_cols; i++) {
            col_idx = col_order[i]
            columns[col_idx] = substr($0, start_index, col_lengths[col_idx])
            start_index += col_lengths[col_idx]
        }

        # Rebuild intermediate result row by row
        result = ""
        for (j = 1; j <= col_lengths[1]; j++) {
            for (k = 1; k <= num_cols; k++) {
                if (j <= length(columns[k])) {
                    result = result substr(columns[k], j, 1)
                }
            }
        }
    }
    END {
        print result
    }')



    # Decode symbol pairs back to plaintext
    adfgvx_result=""
    adfgvx_i=1
    while [ "$adfgvx_i" -le "$adfgvx_length" ]; do
        adfgvx_pair=$(printf "%s" "$adfgvx_reverse_result" | cut -c "$adfgvx_i"-"$((adfgvx_i + 1))")
        adfgvx_symbol1=$(printf "%s" "$adfgvx_pair" | cut -c1)
        adfgvx_symbol2=$(printf "%s" "$adfgvx_pair" | cut -c2)

        case $adfgvx_symbol1 in
            A) adfgvx_row=0 ;;
            D) adfgvx_row=1 ;;
            F) adfgvx_row=2 ;;
            G) adfgvx_row=3 ;;
            V) adfgvx_row=4 ;;
            X) adfgvx_row=5 ;;
        esac

        case $adfgvx_symbol2 in
            A) adfgvx_col=0 ;;
            D) adfgvx_col=1 ;;
            F) adfgvx_col=2 ;;
            G) adfgvx_col=3 ;;
            V) adfgvx_col=4 ;;
            X) adfgvx_col=5 ;;
        esac

        adfgvx_index=$(( adfgvx_row * 6 + adfgvx_col ))
        adfgvx_mapped_char=$(echo "$adfgvx_keysquare" | cut -c $((adfgvx_index + 1)))

        adfgvx_result=$(printf "%s%s" "$adfgvx_result" "$adfgvx_mapped_char")
        adfgvx_i=$((adfgvx_i + 2))
    done

    printf "%s\n" "$adfgvx_result"
    else
        echo "Error: Invalid mode. Use 'encrypt' or 'decrypt'." >&2
        return 1
    fi
}

# Simple Substitution Cipher - monoalphabetic substitution with keyword
simple_substitution_cipher() {
    sub_text="$1"
    sub_key="$2"
    sub_mode="$3"
    sub_result=""
    sub_char=""
    sub_pos=""
    sub_upper_text=""
    sub_upper_key=""
    sub_alphabet=""
    sub_cipher_alphabet=""
    sub_i=""

    # Standard alphabet
    sub_alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    # Normalize key: uppercase, remove duplicates while preserving order
    sub_upper_key=$(echo "$sub_key" | tr 'a-z' 'A-Z' | tr -cd 'A-Z')

    # Build cipher alphabet: unique key letters followed by remaining alphabet letters
    sub_cipher_alphabet=""
    for sub_i in $(echo "$sub_upper_key" | grep -o .); do
        if ! echo "$sub_cipher_alphabet" | grep -q "$sub_i"; then
            sub_cipher_alphabet="$sub_cipher_alphabet$sub_i"
        fi
    done
    for sub_i in $(echo "$sub_alphabet" | grep -o .); do
        if ! echo "$sub_cipher_alphabet" | grep -q "$sub_i"; then
            sub_cipher_alphabet="$sub_cipher_alphabet$sub_i"
        fi
    done

    # Normalize text
    sub_upper_text=$(echo "$sub_text" | tr 'a-z' 'A-Z')

    if [ "$sub_mode" = "decrypt" ]; then
        # Swap alphabet and cipher alphabet for decryption
        sub_tmp="$sub_alphabet"
        sub_alphabet="$sub_cipher_alphabet"
        sub_cipher_alphabet="$sub_tmp"
    fi

    # Process each character
    for sub_i in $(seq 1 ${#sub_upper_text}); do
        sub_char=$(echo "$sub_upper_text" | cut -c $sub_i)
        sub_pos=$(expr index "$sub_alphabet" "$sub_char")
        if [ "$sub_pos" -gt 0 ]; then
            sub_result="$sub_result$(echo "$sub_cipher_alphabet" | cut -c $sub_pos)"
        else
            sub_result="$sub_result$sub_char"
        fi
    done

    echo "$sub_result"
}

# Polybius Square Cipher - maps letters to row/column coordinates
polybius_cipher() {
    poly_text="$1"
    poly_key="$2"
    poly_mode="$3"
    poly_result=""
    poly_char=""
    poly_pos=""
    poly_row=""
    poly_col=""
    poly_index=""
    poly_square=""
    poly_i=""

    # Create square: key (unique, J=I) followed by remaining letters
    poly_square=""
    poly_key=$(echo "$poly_key" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -cd 'A-Z')
    for poly_i in $(echo "$poly_key" | grep -o .); do
        if ! echo "$poly_square" | grep -q "$poly_i"; then
            poly_square="$poly_square$poly_i"
        fi
    done
    for poly_i in A B C D E F G H I K L M N O P Q R S T U V W X Y Z; do
        if ! echo "$poly_square" | grep -q "$poly_i"; then
            poly_square="$poly_square$poly_i"
        fi
    done

    # Process based on mode
    if [ "$poly_mode" = "encrypt" ]; then
        poly_text=$(echo "$poly_text" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -d ' ')
        for poly_i in $(seq 1 ${#poly_text}); do
            poly_char=$(echo "$poly_text" | cut -c $poly_i)
            poly_pos=$(expr index "$poly_square" "$poly_char")
            if [ "$poly_pos" -gt 0 ]; then
                poly_row=$(( (poly_pos - 1) / 5 + 1 ))
                poly_col=$(( (poly_pos - 1) % 5 + 1 ))
                poly_result="$poly_result$poly_row$poly_col"
            else
                echo "Error: Invalid character '$poly_char' in input" >&2
                return 1
            fi
        done
    else
        # Decrypt: pairs of digits
        poly_text=$(echo "$poly_text" | tr -d ' ')
        if [ $(( ${#poly_text} % 2 )) -ne 0 ]; then
            echo "Error: Ciphertext must have even number of digits for decryption" >&2
            return 1
        fi
        poly_i=1
        while [ $poly_i -le ${#poly_text} ]; do
            poly_row=$(echo "$poly_text" | cut -c $poly_i)
            poly_col=$(echo "$poly_text" | cut -c $((poly_i + 1)))
            if [ "$poly_row" -ge 1 ] && [ "$poly_row" -le 5 ] && [ "$poly_col" -ge 1 ] && [ "$poly_col" -le 5 ]; then
                poly_index=$(( (poly_row - 1) * 5 + poly_col ))
                poly_result="$poly_result$(echo "$poly_square" | cut -c $poly_index)"
            else
                echo "Error: Invalid coordinate ($poly_row, $poly_col)" >&2
                return 1
            fi
            poly_i=$((poly_i + 2))
        done
    fi

    echo "$poly_result"
}

# Bacon Cipher - encodes letters as 5-bit binary using A/B
bacon_cipher() {
    bacon_text="$1"
    bacon_mode="$2"
    bacon_result=""
    bacon_char=""
    bacon_code=""
    bacon_upper=""
    bacon_i=""
    bacon_j=""

    # Baconian alphabet (24 letters: I=J, U=V in classic version, but we use 26)
    # Classic: A=aaaaa, B=aaaab, ..., Z=bbaba (I/J and U/V share codes)
    bacon_upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    if [ "$bacon_mode" = "encrypt" ]; then
        bacon_text=$(echo "$bacon_text" | tr 'a-z' 'A-Z' | tr -cd 'A-Z')
        for bacon_i in $(seq 1 ${#bacon_text}); do
            bacon_char=$(echo "$bacon_text" | cut -c $bacon_i)
            bacon_pos=$(expr index "$bacon_upper" "$bacon_char")
            if [ "$bacon_pos" -gt 0 ]; then
                # Convert position-1 to 5-bit binary, A=0, B=1
                bacon_pos=$((bacon_pos - 1))
                bacon_code=""
                for bacon_j in 5 4 3 2 1; do
                    if [ $((bacon_pos % 2)) -eq 1 ]; then
                        bacon_code="B$bacon_code"
                    else
                        bacon_code="A$bacon_code"
                    fi
                    bacon_pos=$((bacon_pos / 2))
                done
                bacon_result="$bacon_result$bacon_code"
            fi
        done
    else
        # Decrypt: process in groups of 5
        bacon_text=$(echo "$bacon_text" | tr 'a-z' 'A-Z' | tr -cd 'AB')
        if [ $(( ${#bacon_text} % 5 )) -ne 0 ]; then
            echo "Error: Ciphertext length must be multiple of 5 for decryption" >&2
            return 1
        fi
        bacon_i=1
        while [ $bacon_i -le ${#bacon_text} ]; do
            bacon_code=""
            for bacon_j in 0 1 2 3 4; do
                bacon_char=$(echo "$bacon_text" | cut -c $((bacon_i + bacon_j)))
                bacon_code="$bacon_code$bacon_char"
            done
            # Convert 5 A/B to binary to position
            bacon_pos=0
            for bacon_j in 1 2 3 4 5; do
                bacon_char=$(echo "$bacon_code" | cut -c $bacon_j)
                bacon_pos=$((bacon_pos * 2))
                if [ "$bacon_char" = "B" ]; then
                    bacon_pos=$((bacon_pos + 1))
                fi
            done
            bacon_result="$bacon_result$(echo "$bacon_upper" | cut -c $((bacon_pos + 1)))"
            bacon_i=$((bacon_i + 5))
        done
    fi

    echo "$bacon_result"
}

# Columnar Transposition Cipher
columnar_transposition_cipher() {
    ct_text="$1"
    ct_key="$2"
    ct_mode="$3"
    ct_result=""
    ct_upper_key=""
    ct_upper_text=""
    ct_num_cols=""
    ct_num_rows=""
    ct_total_len=""
    ct_i=""
    ct_j=""
    ct_pos=""
    ct_col_chars=""
    ct_row=""
    ct_col=""
    ct_idx=""
    ct_order=""
    ct_inverse_order=""

    # Normalize
    ct_upper_key=$(echo "$ct_key" | tr 'a-z' 'A-Z' | tr -cd 'A-Z')
    ct_upper_text=$(echo "$ct_text" | tr 'a-z' 'A-Z' | tr -d ' ')

    ct_num_cols=${#ct_upper_key}
    ct_total_len=${#ct_upper_text}
    ct_num_rows=$(( (ct_total_len + ct_num_cols - 1) / ct_num_cols ))

    # Pad text if needed for encryption
    if [ "$ct_mode" = "encrypt" ]; then
        while [ $(( ${#ct_upper_text} % ct_num_cols )) -ne 0 ]; do
            ct_upper_text="${ct_upper_text}X"
        done
        ct_total_len=${#ct_upper_text}
        ct_num_rows=$((ct_total_len / ct_num_cols))
    fi

    # Calculate column order based on key letter positions (1-indexed, sorted by letter)
    # For key "KEY": E(1), K(0), Y(2) -> order: 1, 0, 2 (K is col 0, E is col 1, Y is col 2)
    ct_order=""
    ct_inverse_order=""
    for ct_i in $(seq 1 $ct_num_cols); do
        ct_pos=$(echo "$ct_upper_key" | fold -w1 | nl -nln | sort -k2 | awk -v n="$ct_i" 'NR==n {print $1}')
        ct_order="$ct_order $ct_pos"
        ct_inverse_order="$ct_inverse_order"
    done
    
    # Get the reading order for columns (which column position to read first, second, etc.)
    ct_order=$(echo "$ct_upper_key" | fold -w1 | nl -nln | sort -k2 | awk '{print $1}')

    if [ "$ct_mode" = "encrypt" ]; then
        # Read columns in sorted key order
        for ct_col_pos in $ct_order; do
            ct_col=$((ct_col_pos - 1))
            ct_j=$ct_col
            while [ $ct_j -lt $ct_total_len ]; do
                ct_result="$ct_result$(echo "$ct_upper_text" | cut -c $((ct_j + 1)))"
                ct_j=$((ct_j + ct_num_cols))
            done
        done
    else
        # Decryption: Calculate how many chars per column, fill columns in sorted key order, read in original order
        ct_num_rows=$((ct_total_len / ct_num_cols))
        
        # Initialize column strings
        for ct_i in $(seq 1 $ct_num_cols); do
            eval "ct_col_$ct_i=''"
        done
        
        # Fill columns in sorted key order
        ct_idx=1
        for ct_col_pos in $ct_order; do
            eval "ct_col_${ct_col_pos}=\$(echo \"\$ct_upper_text\" | cut -c ${ct_idx}-$((ct_idx + ct_num_rows - 1)))"
            ct_idx=$((ct_idx + ct_num_rows))
        done
        
        # Read rows in original key order (left to right)
        for ct_row in $(seq 1 $ct_num_rows); do
            for ct_col in $(seq 1 $ct_num_cols); do
                eval "ct_col_chars=\"\$ct_col_${ct_col}\""
                ct_char=$(echo "$ct_col_chars" | cut -c $ct_row)
                ct_result="$ct_result$ct_char"
            done
        done
    fi

    echo "$ct_result"
}

# Autokey Cipher - Vigenère with plaintext appended to key
autokey_cipher() {
    ak_text="$1"
    ak_key="$2"
    ak_mode="$3"
    ak_result=""
    ak_full_key=""
    ak_char_text=""
    ak_char_key=""
    ak_val_text=""
    ak_val_key=""
    ak_shift=""
    ak_i=""

    # Normalize
    ak_text=$(echo "$ak_text" | tr 'a-z' 'A-Z' | tr -d ' ')
    ak_key=$(echo "$ak_key" | tr 'a-z' 'A-Z' | tr -d ' ')

    if [ "$ak_mode" = "encrypt" ]; then
        # Key + plaintext (without last char) = full key
        ak_full_key="${ak_key}${ak_text}"
        for ak_i in $(seq 1 ${#ak_text}); do
            ak_char_text=$(echo "$ak_text" | cut -c $ak_i)
            ak_char_key=$(echo "$ak_full_key" | cut -c $ak_i)
            ak_val_text=$(($(printf '%d' "'$ak_char_text") - 65))
            ak_val_key=$(($(printf '%d' "'$ak_char_key") - 65))
            ak_shift=$(( (ak_val_text + ak_val_key) % 26 + 65 ))
            ak_result="$ak_result$(printf "\\$(printf '%03o' $ak_shift)")"
        done
    else
        # Decryption: key expands as we decrypt
        for ak_i in $(seq 1 ${#ak_text}); do
            ak_char_text=$(echo "$ak_text" | cut -c $ak_i)
            if [ $ak_i -le ${#ak_key} ]; then
                ak_char_key=$(echo "$ak_key" | cut -c $ak_i)
            else
                ak_char_key=$(echo "$ak_result" | cut -c $((ak_i - ${#ak_key})))
            fi
            ak_val_text=$(($(printf '%d' "'$ak_char_text") - 65))
            ak_val_key=$(($(printf '%d' "'$ak_char_key") - 65))
            ak_shift=$(( (ak_val_text - ak_val_key + 26) % 26 + 65 ))
            ak_result="$ak_result$(printf "\\$(printf '%03o' $ak_shift)")"
        done
    fi

    echo "$ak_result"
}

# Gronsfeld Cipher - Vigenère with numeric key
gronsfeld_cipher() {
    gr_text="$1"
    gr_key="$2"
    gr_mode="$3"
    gr_result=""
    gr_char=""
    gr_key_digit=""
    gr_val=""
    gr_shift=""
    gr_i=""
    gr_key_len=""

    # Normalize text
    gr_text=$(echo "$gr_text" | tr 'a-z' 'A-Z' | tr -d ' ')
    gr_key=$(echo "$gr_key" | tr -cd '0-9')
    gr_key_len=${#gr_key}

    # Validate key
    if [ -z "$gr_key" ]; then
        echo "Error: Key must contain digits only" >&2
        return 1
    fi

    for gr_i in $(seq 1 ${#gr_text}); do
        gr_char=$(echo "$gr_text" | cut -c $gr_i)
        gr_key_digit=$(echo "$gr_key" | cut -c $(( (gr_i - 1) % gr_key_len + 1 )))
        gr_val=$(($(printf '%d' "'$gr_char") - 65))

        if [ "$gr_mode" = "encrypt" ]; then
            gr_shift=$(( (gr_val + gr_key_digit) % 26 + 65 ))
        else
            gr_shift=$(( (gr_val - gr_key_digit + 26) % 26 + 65 ))
        fi
        gr_result="$gr_result$(printf "\\$(printf '%03o' $gr_shift)")"
    done

    echo "$gr_result"
}

# Porta Cipher - uses 13 alphabets (one for each key letter pair)
porta_cipher() {
    porta_text="$1"
    porta_key="$2"
   porta_mode="$3"
    porta_result=""
    porta_char_text=""
    porta_char_key=""
    porta_key_idx=""
   porta_alphabet_idx=""
   porta_plain_idx=""
   porta_cipher_idx=""
   porta_i=""

    # Porta tableau: 13 rows, each row shifts differently
    # Row N (key letter N) shifts position N in the alphabet to A
    # A/B: NOPQRSTUVWXYZABCDEFGHIJKLM
    # C/D: OPQRSTUVWXYZABCDEFGHIJKLMN
    # etc.
    porta_text=$(echo "$porta_text" | tr 'a-z' 'A-Z' | tr -d ' ')
    porta_key=$(echo "$porta_key" | tr 'a-z' 'A-Z' | tr -d ' ')

    for porta_i in $(seq 1 ${#porta_text}); do
        porta_char_text=$(echo "$porta_text" | cut -c $porta_i)
        porta_char_key=$(echo "$porta_key" | cut -c $(( (porta_i - 1) % ${#porta_key} + 1 )))

        # Convert key letter to row (A/B=0, C/D=1, ..., Y/Z=12)
        porta_key_idx=$(( ($(printf '%d' "'$porta_char_key") - 65) / 2 ))

        # Plaintext position
        porta_plain_idx=$(($(printf '%d' "'$porta_char_text") - 65))

        # Porta is self-reciprocal: same operation for encrypt/decrypt
        # Row porta_key_idx defines the mapping
        if [ "$porta_mode" = "encrypt" ]; then
            # For encryption: if plain in first half (0-12), cipher is mapped from second half
            # If plain in second half (13-25), cipher is mapped from first half
            if [ $porta_plain_idx -lt 13 ]; then
                porta_cipher_idx=$(( 13 + (porta_plain_idx + porta_key_idx) % 13 ))
            else
                porta_cipher_idx=$(( (porta_plain_idx - 13 - porta_key_idx + 13) % 13 ))
            fi
        else
            # Decryption is the same as encryption in Porta
            if [ $porta_plain_idx -lt 13 ]; then
                porta_cipher_idx=$(( 13 + (porta_plain_idx + porta_key_idx) % 13 ))
            else
                porta_cipher_idx=$(( (porta_plain_idx - 13 - porta_key_idx + 13) % 13 ))
            fi
        fi

        porta_result="$porta_result$(printf "\\$(printf '%03o' $((porta_cipher_idx + 65)))")"
    done

    echo "$porta_result"
}

# Bifid Cipher - combines Polybius square with transposition
bifid_cipher() {
    bifid_text="$1"
    bifid_key="$2"
    bifid_mode="$3"
    bifid_result=""
    bifid_char=""
    bifid_pos=""
    bifid_row=""
    bifid_col=""
    bifid_square=""
    bifid_rows=""
    bifid_cols=""
    bifid_combined=""
    bifid_i=""

    # Create square: key + remaining letters (J=I)
    bifid_square=""
    bifid_key=$(echo "$bifid_key" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -cd 'A-Z')
    for bifid_i in $(echo "$bifid_key" | grep -o .); do
        if ! echo "$bifid_square" | grep -q "$bifid_i"; then
            bifid_square="$bifid_square$bifid_i"
        fi
    done
    for bifid_i in A B C D E F G H I K L M N O P Q R S T U V W X Y Z; do
        if ! echo "$bifid_square" | grep -q "$bifid_i"; then
            bifid_square="$bifid_square$bifid_i"
        fi
    done

    # Normalize text
    bifid_text=$(echo "$bifid_text" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -d ' ')

    if [ "$bifid_mode" = "encrypt" ]; then
        # Get row and column coordinates
        bifid_rows=""
        bifid_cols=""
        for bifid_i in $(seq 1 ${#bifid_text}); do
            bifid_char=$(echo "$bifid_text" | cut -c $bifid_i)
            bifid_pos=$(expr index "$bifid_square" "$bifid_char")
            bifid_row=$(( (bifid_pos - 1) / 5 + 1 ))
            bifid_col=$(( (bifid_pos - 1) % 5 + 1 ))
            bifid_rows="$bifid_rows$bifid_row"
            bifid_cols="$bifid_cols$bifid_col"
        done

        # Combine: rows followed by cols, then read pairs
        bifid_combined="$bifid_rows$bifid_cols"
        bifid_i=1
        while [ $bifid_i -le ${#bifid_combined} ]; do
            bifid_row=$(echo "$bifid_combined" | cut -c $bifid_i)
            bifid_col=$(echo "$bifid_combined" | cut -c $((bifid_i + 1)))
            bifid_pos=$(( (bifid_row - 1) * 5 + bifid_col ))
            bifid_result="$bifid_result$(echo "$bifid_square" | cut -c $bifid_pos)"
            bifid_i=$((bifid_i + 2))
        done
    else
        # Decrypt: convert to coords, split in half, read row/col pairs
        bifid_combined=""
        for bifid_i in $(seq 1 ${#bifid_text}); do
            bifid_char=$(echo "$bifid_text" | cut -c $bifid_i)
            bifid_pos=$(expr index "$bifid_square" "$bifid_char")
            bifid_row=$(( (bifid_pos - 1) / 5 + 1 ))
            bifid_col=$(( (bifid_pos - 1) % 5 + 1 ))
            bifid_combined="$bifid_combined$bifid_row$bifid_col"
        done

        # Split in half
        bifid_rows=$(echo "$bifid_combined" | cut -c 1-$(( ${#bifid_text} )))
        bifid_cols=$(echo "$bifid_combined" | cut -c $(( ${#bifid_text} + 1 ))-)

        for bifid_i in $(seq 1 ${#bifid_text}); do
            bifid_row=$(echo "$bifid_rows" | cut -c $bifid_i)
            bifid_col=$(echo "$bifid_cols" | cut -c $bifid_i)
            bifid_pos=$(( (bifid_row - 1) * 5 + bifid_col ))
            bifid_result="$bifid_result$(echo "$bifid_square" | cut -c $bifid_pos)"
        done
    fi

    echo "$bifid_result"
}

# Four-Square Cipher - uses four 5x5 squares
foursquare_cipher() {
    fsq_text="$1"
    fsq_key1="$2"
    fsq_key2="$3"
    fsq_mode="$4"
    fsq_result=""
    fsq_char1=""
    fsq_char2=""
    fsq_pos1=""
    fsq_pos2=""
    fsq_row1=""
    fsq_col1=""
    fsq_row2=""
    fsq_col2=""
    fsq_sq1=""
    fsq_sq2=""
    fsq_alpha=""
    fsq_i=""

    # Standard alphabet (no J)
    fsq_alpha="ABCDEFGHIKLMNOPQRSTUVWXYZ"

    # Build square 1 (upper right): key1 + remaining
    fsq_sq1=""
    fsq_key1=$(echo "$fsq_key1" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -cd 'A-Z')
    for fsq_i in $(echo "$fsq_key1" | grep -o .); do
        if ! echo "$fsq_sq1" | grep -q "$fsq_i"; then
            fsq_sq1="$fsq_sq1$fsq_i"
        fi
    done
    for fsq_i in $(echo "$fsq_alpha" | grep -o .); do
        if ! echo "$fsq_sq1" | grep -q "$fsq_i"; then
            fsq_sq1="$fsq_sq1$fsq_i"
        fi
    done

    # Build square 2 (lower left): key2 + remaining
    fsq_sq2=""
    fsq_key2=$(echo "$fsq_key2" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -cd 'A-Z')
    for fsq_i in $(echo "$fsq_key2" | grep -o .); do
        if ! echo "$fsq_sq2" | grep -q "$fsq_i"; then
            fsq_sq2="$fsq_sq2$fsq_i"
        fi
    done
    for fsq_i in $(echo "$fsq_alpha" | grep -o .); do
        if ! echo "$fsq_sq2" | grep -q "$fsq_i"; then
            fsq_sq2="$fsq_sq2$fsq_i"
        fi
    done

    # Normalize text: uppercase, J->I, remove non-alpha, pad if odd
    fsq_text=$(echo "$fsq_text" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -cd 'A-Z')
    if [ $(( ${#fsq_text} % 2 )) -ne 0 ]; then
        fsq_text="${fsq_text}X"
    fi

    # Process digraphs
    fsq_i=1
    while [ $fsq_i -le ${#fsq_text} ]; do
        fsq_char1=$(echo "$fsq_text" | cut -c $fsq_i)
        fsq_char2=$(echo "$fsq_text" | cut -c $((fsq_i + 1)))

        # Find positions in standard alphabet
        fsq_pos1=$(expr index "$fsq_alpha" "$fsq_char1")
        fsq_pos2=$(expr index "$fsq_alpha" "$fsq_char2")

        fsq_row1=$(( (fsq_pos1 - 1) / 5 ))
        fsq_col1=$(( (fsq_pos1 - 1) % 5 ))
        fsq_row2=$(( (fsq_pos2 - 1) / 5 ))
        fsq_col2=$(( (fsq_pos2 - 1) % 5 ))

        if [ "$fsq_mode" = "encrypt" ]; then
            # Encrypt: row1/col2 from sq1, row2/col1 from sq2
            fsq_result="$fsq_result$(echo "$fsq_sq1" | cut -c $((fsq_row1 * 5 + fsq_col2 + 1)))"
            fsq_result="$fsq_result$(echo "$fsq_sq2" | cut -c $((fsq_row2 * 5 + fsq_col1 + 1)))"
        else
            # Decrypt: reverse the process
            # Find char1 in sq1, char2 in sq2
            fsq_pos1=$(expr index "$fsq_sq1" "$fsq_char1")
            fsq_pos2=$(expr index "$fsq_sq2" "$fsq_char2")

            fsq_row1=$(( (fsq_pos1 - 1) / 5 ))
            fsq_col1=$(( (fsq_pos1 - 1) % 5 ))
            fsq_row2=$(( (fsq_pos2 - 1) / 5 ))
            fsq_col2=$(( (fsq_pos2 - 1) % 5 ))

            # Map back to standard alphabet positions
            fsq_result="$fsq_result$(echo "$fsq_alpha" | cut -c $((fsq_row1 * 5 + fsq_col2 + 1)))"
            fsq_result="$fsq_result$(echo "$fsq_alpha" | cut -c $((fsq_row2 * 5 + fsq_col1 + 1)))"
        fi

        fsq_i=$((fsq_i + 2))
    done

    echo "$fsq_result"
}


# Main script logic
usage() {
    echo "Usage: $0 -c cipher -m mode -t text [-s shift] [-a a] [-b b] [-k key] [-2 key2] [-q keysquare]"
    echo "cipher: adfgvx, affine, atbash, autokey, bacon, beaufort, bifid, caesar,"
    echo "        columnar, foursquare, gronsfeld, hill, nihilist, playfair, polybius,"
    echo "        porta, railfence, rot13, simple, substitution, trithemius, or vigenere"
    echo "mode: encrypt or decrypt"
    echo "text: text to be encrypted or decrypted"
    echo "shift: shift value for Caesar Cipher (default: 3)"
    echo "a: multiplier value for Affine Cipher (default: 5)"
    echo "b: additive value for Affine Cipher (default: 8)"
    echo "key: key for ciphers that use a single key"
    echo "key2 (-2): second key for Four-Square Cipher"
    echo "keysquare: keysquare for ADFGVX Cipher"
    exit 1
}

while getopts ":c:m:t:s:a:b:k:q:2:" opt; do
    case "$opt" in
        a) a="$OPTARG" ;;
        b) b="$OPTARG" ;;
        c) cipher="$OPTARG" ;;
        k) key="$OPTARG" ;;
        m) mode="$OPTARG" ;;
        q) keysquare="$OPTARG" ;;
        s) shift="$OPTARG" ;;
        t) text="$OPTARG" ;;
        2) key2="$OPTARG" ;;
        *) usage ;;
    esac
done

# Validate required arguments
[ -z "$cipher" ] || [ -z "$mode" ] || [ -z "$text" ] && usage

# Default values for optional arguments
shift="${shift:-3}"
a="${a:-5}"
b="${b:-8}"
key="${key:-KEY}"
key2="${key2:-KEY}"

# Dispatch cipher functions based on the provided cipher type
case "$cipher" in
    adfgvx) adfgvx_cipher "$text" "$key" "$mode" "$keysquare" ;;
    affine) affine_cipher "$text" "$a" "$b" "$mode" ;;
    atbash) atbash "$text" ;;
    autokey) autokey_cipher "$text" "$key" "$mode" ;;
    bacon) bacon_cipher "$text" "$mode" ;;
    beaufort) beaufort_cipher "$text" "$key" "$mode" ;;
    bifid) bifid_cipher "$text" "$key" "$mode" ;;
    caesar) caesar_cipher "$text" "$shift" "$mode" ;;
    columnar) columnar_transposition_cipher "$text" "$key" "$mode" ;;
    foursquare) foursquare_cipher "$text" "$key" "$key2" "$mode" ;;
    gronsfeld) gronsfeld_cipher "$text" "$key" "$mode" ;;
    hill) hill_cipher "$text" "$key" "$mode" ;;
    nihilist) nihilist_cipher "$text" "$key" "$mode" ;;
    playfair) playfair_cipher "$text" "$key" "$mode" ;;
    polybius) polybius_cipher "$text" "$key" "$mode" ;;
    porta) porta_cipher "$text" "$key" "$mode" ;;
    railfence) railfence_cipher "$text" "$key" "$mode" ;;
    rot13) rot13 "$text" ;;
    simple|substitution) simple_substitution_cipher "$text" "$key" "$mode" ;;
    trithemius) trithemius_cipher "$text" "$mode" ;;
    vigenere) vigenere_cipher "$text" "$key" "$mode" ;;
    *) usage ;;
esac
