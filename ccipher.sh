#!/bin/sh
# A collection of classical ciphers in pure POSIX.
# License: CC0 1.0 Universal

# Function to perform Caesar Cipher encryption/decryption
caesar_cipher() {
    local text="$1"
    local shift="$2"
    local mode="$3"
    local result=""
    local char
    local ascii

    if [ "$shift" -lt 0 ] || [ "$shift" -ge 26 ]; then
        echo "Error: Shift value must be between 0 and 25."
        return 1
    fi

    if [ "$mode" = "decrypt" ]; then
        shift=$((26 - shift))
    fi

    while [ -n "$text" ]; do
        char="${text%"${text#?}"}"
        text="${text#?}"
        ascii=$(printf "%d" "'$char")

        if [ "$char" = " " ]; then
            result="$result$char"
        else
            if [ "$ascii" -ge 65 ] && [ "$ascii" -le 90 ]; then
                ascii=$(( (ascii - 65 + shift) % 26 + 65 ))
            elif [ "$ascii" -ge 97 ] && [ "$ascii" -le 122 ]; then
                ascii=$(( (ascii - 97 + shift) % 26 + 97 ))
            fi
            result="$result$(printf "\\$(printf "%o" $ascii)")"
        fi
    done

    echo "$result"
}

# Function to perform Affine Cipher encryption/decryption
affine_cipher() {
    local text="$1"
    local a="$2"
    local b="$3"
    local mode="$4"
    local result=""
    local char
    local ascii
    local inv_a=0

    # Check if a and b are within valid range
    if [ "$a" -le 0 ] || [ "$a" -ge 26 ] || [ "$b" -lt 0 ] || [ "$b" -ge 26 ]; then
        echo "Error: 'a' must be between 1 and 25, 'b' must be between 0 and 25."
        return 1
    fi

    if [ "$mode" = "decrypt" ]; then
        inv_a=$(mod_inverse "$a" 26)
        if [ "$?" -ne 0 ]; then
            echo "Error: 'a' has no modular inverse."
            return 1
        fi
    fi

    while [ -n "$text" ]; do
        char="${text%"${text#?}"}"
        text="${text#?}"
        ascii=$(printf "%d" "'$char")

        if [ "$char" = " " ]; then
            result="$result$char"
        else
            if [ "$ascii" -ge 65 ] && [ "$ascii" -le 90 ]; then
                if [ "$mode" = "encrypt" ]; then
                    ascii=$(( (a * (ascii - 65) + b) % 26 + 65 ))
                else
                    ascii=$(( (inv_a * (ascii - 65 - b + 26)) % 26 + 65 ))
                fi
            elif [ "$ascii" -ge 97 ] && [ "$ascii" -le 122 ]; then
                if [ "$mode" = "encrypt" ]; then
                    ascii=$(( (a * (ascii - 97) + b) % 26 + 97 ))
                else
                    ascii=$(( (inv_a * (ascii - 97 - b + 26)) % 26 + 97 ))
                fi
            fi
            result="$result$(printf "\\$(printf "%o" $ascii)")"
        fi
    done

    echo "$result"
}

# Function to perform Rot13 encryption/decryption
rot13() {
    local text="$1"
    local result=""
    local char
    local ascii

    while [ -n "$text" ]; do
        char="${text%"${text#?}"}"
        text="${text#?}"
        ascii=$(printf "%d" "'$char")

        if [ "$char" = " " ]; then
            result="$result$char"
        else
            if [ "$ascii" -ge 65 ] && [ "$ascii" -le 90 ]; then
                ascii=$(( (ascii - 65 + 13) % 26 + 65 ))
            elif [ "$ascii" -ge 97 ] && [ "$ascii" -le 122 ]; then
                ascii=$(( (ascii - 97 + 13) % 26 + 97 ))
            fi
            result="$result$(printf "\\$(printf "%o" $ascii)")"
        fi
    done

    echo "$result"
}

# Function to perform Atbash encryption/decryption
atbash() {
    local text="$1"
    local result=""
    local char
    local ascii

    while [ -n "$text" ]; do
        char="${text%"${text#?}"}"
        text="${text#?}"
        ascii=$(printf "%d" "'$char")

        if [ "$char" = " " ]; then
            result="$result$char"
        else
            if [ "$ascii" -ge 65 ] && [ "$ascii" -le 90 ]; then
                ascii=$(( 155 - ascii ))
            elif [ "$ascii" -ge 97 ] && [ "$ascii" -le 122 ]; then
                ascii=$(( 219 - ascii ))
            fi
            result="$result$(printf "\\$(printf "%o" $ascii)")"
        fi
    done

    echo "$result"
}

# Function to calculate modular inverse
mod_inverse() {
    local a="$1"
    local m="$2"
    local t=0
    local new_t=1
    local r="$m"
    local new_r="$a"
    local quotient
    local temp

    while [ "$new_r" -ne 0 ]; do
        quotient=$(( r / new_r ))
        temp=$new_t
        new_t=$(( t - quotient * new_t ))
        t="$temp"
        temp=$new_r
        new_r=$(( r - quotient * new_r ))
        r="$temp"
    done

    if [ "$r" -gt 1 ]; then
        echo "No inverse"
        return 1
    fi

    if [ "$t" -lt 0 ]; then
        t=$(( t + m ))
    fi

    echo "$t"
}


generate_playfair_matrix() {
    local key=$(echo "$1" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -d '[:space:]')
    local alphabet="ABCDEFGHIKLMNOPQRSTUVWXYZ"
    local matrix=""
    local used=""

    for char in $(echo "$key" | grep -o .); do
        if ! echo "$used" | grep -q "$char"; then
            used="$used$char"
            matrix="$matrix$char"
        fi
    done

    for char in $(echo "$alphabet" | grep -o .); do
        if ! echo "$used" | grep -q "$char"; then
            matrix="$matrix$char"
        fi
    done

    echo "$matrix"
}

prepare_playfair_text() {
    local text=$(echo "$1" | tr -d '[:space:]' | tr 'a-z' 'A-Z' | tr 'J' 'I')
    local prepared=""
    local i

    while [ -n "$text" ]; do
        char1=$(echo "$text" | cut -c 1)
        text=$(echo "$text" | cut -c 2-)
        char2=$(echo "$text" | cut -c 1)

        if [ -z "$char2" ] || [ "$char1" = "$char2" ]; then
            char2="X"
        else
            text=$(echo "$text" | cut -c 2-)
        fi

        prepared="$prepared$char1$char2"
    done

    if [ $((${#prepared} % 2)) -ne 0 ]; then
        prepared="${prepared}X"
    fi

    echo "$prepared"
}

playfair_cipher() {
    local text=$(prepare_playfair_text "$1")
    local key_matrix=$(generate_playfair_matrix "$2")
    local mode="$3"
    local result=""
    local pos1 pos2 row1 col1 row2 col2 char1 char2 i

    for i in $(seq 1 2 ${#text}); do
        char1=$(echo "$text" | cut -c $i)
        char2=$(echo "$text" | cut -c $((i+1)))

        pos1=$(expr index "$key_matrix" "$char1")
        pos2=$(expr index "$key_matrix" "$char2")

        row1=$(( (pos1 - 1) / 5 ))
        col1=$(( (pos1 - 1) % 5 ))
        row2=$(( (pos2 - 1) / 5 ))
        col2=$(( (pos2 - 1) % 5 ))

        if [ "$row1" -eq "$row2" ]; then
            if [ "$mode" = "encrypt" ]; then
                col1=$(( (col1 + 1) % 5 ))
                col2=$(( (col2 + 1) % 5 ))
            else
                col1=$(( (col1 + 4) % 5 ))
                col2=$(( (col2 + 4) % 5 ))
            fi
        elif [ "$col1" -eq "$col2" ]; then
            if [ "$mode" = "encrypt" ]; then
                row1=$(( (row1 + 1) % 5 ))
                row2=$(( (row2 + 1) % 5 ))
            else
                row1=$(( (row1 + 4) % 5 ))
                row2=$(( (row2 + 4) % 5 ))
            fi
        else
            tmp="$col1"
            col1="$col2"
            col2="$tmp"
        fi

        result="$result$(echo "$key_matrix" | cut -c $((row1 * 5 + col1 + 1)))"
        result="$result$(echo "$key_matrix" | cut -c $((row2 * 5 + col2 + 1)))"
    done

    echo "$result"
}

# Function to generate the repeated key for Vigenère cipher
generate_repeated_key() {
    local text="$1"
    local key="$2"
    local repeated_key=""
    local i

    for i in $(seq 0 $((${#text} - 1))); do
        repeated_key="$repeated_key$(echo "$key" | cut -c $((i % ${#key} + 1)))"
    done

    echo "$repeated_key"
}

# Function to encrypt/decrypt using Vigenère cipher
vigenere_cipher() {
    local text="$1"
    local key="$2"
    local mode="$3"
    local repeated_key
    local result=""
    local char_text char_key
    local ascii_text ascii_key shift

    text=$(echo "$text" | tr 'a-z' 'A-Z' | tr -d ' ')
    key=$(echo "$key" | tr 'a-z' 'A-Z')

    repeated_key=$(generate_repeated_key "$text" "$key")

    for i in $(seq 1 ${#text}); do
        char_text=$(echo "$text" | cut -c $i)
        char_key=$(echo "$repeated_key" | cut -c $i)
        ascii_text=$(printf "%d" "'$char_text")
        ascii_key=$(printf "%d" "'$char_key")

        if [ "$mode" = "encrypt" ]; then
            shift=$(( (ascii_text - 65 + ascii_key - 65) % 26 + 65 ))
        else
            shift=$(( (ascii_text - ascii_key + 26) % 26 + 65 ))
        fi

        result="$result$(printf "\\$(printf "%o" $shift)")"
    done

    echo "$result"
}

# Function to encrypt/decrypt using Beaufort cipher
beaufort_cipher() {
    local text="$1"
    local key="$2"
    local repeated_key
    local result=""
    local char_text char_key
    local ascii_text ascii_key shift

    text=$(echo "$text" | tr 'a-z' 'A-Z' | tr -d ' ')
    key=$(echo "$key" | tr 'a-z' 'A-Z')

    repeated_key=$(generate_repeated_key "$text" "$key")

    for i in $(seq 1 ${#text}); do
        char_text=$(echo "$text" | cut -c $i)
        char_key=$(echo "$repeated_key" | cut -c $i)
        ascii_text=$(printf "%d" "'$char_text")
        ascii_key=$(printf "%d" "'$char_key")

        # Calculate shift for Beaufort cipher (key - plaintext)
        shift=$(( (ascii_key - ascii_text + 26) % 26 + 65 ))

        result="$result$(printf "\\$(printf "%o" $shift)")"
    done

    echo "$result"
}

# Function to encrypt/decrypt using the Trithemius cipher
trithemius_cipher() {
    local text="$1"
    local mode="$2"
    local result=""
    local char_text
    local ascii_text shift
    local i

    # Prepare the input text: uppercase and remove spaces
    text=$(echo "$text" | tr 'a-z' 'A-Z' | tr -d ' ')

    for i in $(seq 1 ${#text}); do
        char_text=$(echo "$text" | cut -c $i)
        ascii_text=$(printf "%d" "'$char_text")

        if [ "$mode" = "encrypt" ]; then
            # Encrypt: Add the progressive key (i-1)
            shift=$(( (ascii_text - 65 + (i - 1)) % 26 + 65 ))
        else
            # Decrypt: Subtract the progressive key (i-1)
            shift=$(( (ascii_text - 65 - (i - 1) + 26) % 26 + 65 ))
        fi

        result="$result$(printf "\\$(printf "%o" $shift)")"
    done

    echo "$result"
}


railfence_cipher() {
    text="$1"
    key="$2"
    mode="$3" # "encrypt" or "decrypt"
    local result=""

    # Check if the key is numeric
    case "$key" in
        ''|*[!0-9]*) echo "Error: Key must be a numeric value."; return 1 ;;
    esac

    # Get the length of the text
    len=${#text}

    # Check if the key is less than 1
    if [ "$key" -lt 1 ]; then
        echo "Error: Key must be at least 1."
        return 1
    fi

    # Check if the key is greater than the length of the text
    if [ "$key" -gt "$len" ]; then
        echo "Error: Key must not exceed the length of the text ($len)."
        return 1
    fi

    # If key is 1, return the text as is
    if [ "$key" -eq 1 ]; then
        echo "$text"
        return
    fi

    if [ "$mode" = "encrypt" ]; then
        # Encrypt the text
        result=$(echo "$text" | awk -v key=$key '
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

    elif [ "$mode" = "decrypt" ]; then
        # Decrypt the text (already fixed earlier)
        result=$(echo "$text" | awk -v key=$key '
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

    echo "$result"
}

nihilist_cipher() {
    local text="$1"
    local key="$2"
    local mode="$3"
    local square="ABCDEFGHIKLMNOPQRSTUVWXYZ" # Polybius square (I/J combined)
    local result=""
    local key_index=1

    # Prepare the key: uppercase, combine I/J
    key=$(printf "%s" "$key" | tr 'a-z' 'A-Z' | tr 'J' 'I')

    # Prepare the ciphertext for decryption (no modification needed for numbers)
    if [ "$mode" = "encrypt" ]; then
        text=$(printf "%s" "$text" | tr 'a-z' 'A-Z' | tr 'J' 'I' | tr -d ' ')
    fi

    while [ -n "$text" ]; do
        # Extract the first block (characters for encryption or numbers for decryption)
        if [ "$mode" = "encrypt" ]; then
            char_text=${text%${text#?}}
            text=${text#?}
        else
            # Extract numeric pairs (ciphertext)
            char_text=${text%% *}
            text=${text#"$char_text"}
            text=$(printf "%s" "$text" | sed 's/^ *//') # Trim leading spaces
        fi

        if [ "$mode" = "encrypt" ]; then
            # Find the numeric coordinate of the plaintext character in the Polybius square
            num_text=$(expr index "$square" "$char_text")
            if [ $num_text -eq 0 ]; then
                echo "Error: Character '$char_text' not found in Polybius square"
                return 1
            fi
            num_text=$(( (num_text - 1) / 5 * 10 + (num_text - 1) % 5 + 11 ))
        else
            # Use numeric ciphertext directly during decryption
            num_text=$char_text
        fi

        # Get the corresponding key character
        char_key=$(printf "%s" "$key" | cut -c "$key_index")
        key_index=$(( (key_index % ${#key}) + 1 ))

        # Find the numeric value for the key character in the Polybius square
        num_key=$(expr index "$square" "$char_key")
        if [ $num_key -eq 0 ]; then
            echo "Error: Key character '$char_key' not found in Polybius square"
            return 1
        fi
        num_key=$(( (num_key - 1) / 5 * 10 + (num_key - 1) % 5 + 11 ))

        if [ "$mode" = "encrypt" ]; then
            cipher_value=$((num_text + num_key))
            result="$result$cipher_value "
        else
            # Decrypt: Adjust for negative values by adding 100 (mod 100 logic)
            cipher_value=$((num_text - num_key))
            if [ "$cipher_value" -lt 0 ]; then
                cipher_value=$((cipher_value + 100))
            fi

            # Validate that cipher value corresponds to a valid Polybius coordinate
            row=$((cipher_value / 10 - 1))
            col=$((cipher_value % 10 - 1))
            index=$((row * 5 + col))
            if [ $row -lt 0 ] || [ $col -lt 0 ] || [ $index -ge ${#square} ]; then
                echo "Error: Decryption failed, invalid cipher value '$cipher_value'"
                return 1
            fi

            # Convert cipher value back to a character
            result="$result$(printf "%s" "$square" | cut -c $((index + 1)))"
        fi
    done

    # Output the result
    printf "%s\n" "$result" | sed 's/ $//'
}

# Helper to find Greatest Common Divisor
gcd() {
    local a="$1"
    local b="$2"
    while [ "$b" -ne 0 ]; do
        local temp=$b
        b=$((a % b))
        a=$temp
    done
    echo "$a"
}




hill_cipher() {
    # Input: mode (encrypt/decrypt), key, text
    text="$1"
    key="$2"
    mode="$3"

    # Extract key values
    k1=$(echo "$key" | cut -d' ' -f1)
    k2=$(echo "$key" | cut -d' ' -f2)
    k3=$(echo "$key" | cut -d' ' -f3)
    k4=$(echo "$key" | cut -d' ' -f4)

    # Validate the determinant of the key matrix
    det=$((k1 * k4 - k2 * k3))
    det=$((det % 26))
    [ "$det" -lt 0 ] && det=$((det + 26))

    # Check if the determinant is coprime with 26
    gcd=$(gcd "$det" 26)  # Function to calculate the GCD
    if [ "$gcd" -ne 1 ]; then
        echo "Error: Invalid key. The determinant ($det) is not coprime with 26." >&2
        return 1
    fi

    det_inv=$(mod_inverse "$det" 26)
    if [ -z "$det_inv" ]; then
        echo "Error: The determinant ($det) is not invertible modulo 26. Decryption is not possible with this key." >&2
        return 1
    fi

    # Adjust key matrix for decryption
    if [ "$mode" = "decrypt" ]; then
        tmp_k1=$k1; tmp_k2=$k2; tmp_k3=$k3; tmp_k4=$k4
        k1=$((det_inv * tmp_k4 % 26))
        k2=$((-det_inv * tmp_k2 % 26))
        k3=$((-det_inv * tmp_k3 % 26))
        k4=$((det_inv * tmp_k1 % 26))
        [ "$k1" -lt 0 ] && k1=$((k1 + 26))
        [ "$k2" -lt 0 ] && k2=$((k2 + 26))
        [ "$k3" -lt 0 ] && k3=$((k3 + 26))
        [ "$k4" -lt 0 ] && k4=$((k4 + 26))
    fi

    # Prepare text: Remove spaces and pad with 'X' if necessary
    clean_text=$(echo "$text" | tr -d '[:space:]' | tr -cd '[:alpha:]' | tr '[:lower:]' '[:upper:]')
    [ "$mode" = "encrypt" ] && [ $(( ${#clean_text} % 2 )) -ne 0 ] && clean_text="${clean_text}X"

    # Initialize result
    result=""

    # Process text in pairs of characters
    while [ -n "$clean_text" ]; do
        char1=$(echo "$clean_text" | cut -c1)
        char2=$(echo "$clean_text" | cut -c2)

        t1=$(( $(printf '%d' "'$char1") - 65 ))
        t2=$(( $(printf '%d' "'$char2") - 65 ))

        res1=$(( (k1 * t1 + k2 * t2) % 26 ))
        res2=$(( (k3 * t1 + k4 * t2) % 26 ))

        [ "$res1" -lt 0 ] && res1=$((res1 + 26))
        [ "$res2" -lt 0 ] && res2=$((res2 + 26))

        e1=$(printf "\\$(printf '%03o' $((res1 + 65)))")
        e2=$(printf "\\$(printf '%03o' $((res2 + 65)))")

        result="$result$e1$e2"
        clean_text=$(echo "$clean_text" | cut -c3-)
    done

    echo "$result"
}


generate_and_print_keysquare() {
    # Create the characters A-Z and 0-9
    chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    # Shuffle the characters using `awk` to ensure randomness
    keysquare=$(printf "%s\n" $(echo "$chars" | fold -w1 | awk 'BEGIN {srand()} {a[NR]=$1}
        END {for (i=NR; i>=1; i--) {j=int(rand()*i)+1; t=a[i]; a[i]=a[j]; a[j]=t}
        for (i=1; i<=NR; i++) printf("%s", a[i])}'))

    # Print the key square as a single line
    if [ "$mode" = "encrypt" ]; then
    printf "Here's a generated ADFGVX Key Square: %s\n" "$keysquare"
    fi
}

adfgvx_cipher() {
    text="$1"
    key="$2"
    mode="$3"
    keysquare="$4"

    # Clean and validate keysquare
    keysquare=$(echo "$keysquare" | tr -d '[:space:]' | tr -d '[:cntrl:]' | tr 'a-z' 'A-Z')
    if [ "$(echo -n "$keysquare" | wc -c)" -ne 36 ]; then
        echo "Error: Keysquare must be exactly 36 characters long." >&2
        generate_and_print_keysquare
        return 1
    fi

    # Clean and prepare input text
    clean_text=$(echo "$text" | tr -d '[:space:]' | tr -d '[:cntrl:]' | tr 'a-z' 'A-Z')

    # Normalize key
    key=$(echo "$key" | tr 'a-z' 'A-Z')  # Consistent normalization

    # Symbols used for the ADFGVX cipher grid
    symbols="ADFGVX"

    if [ "$mode" = "encrypt" ]; then
        # Encryption Logic
        result=""
        length=$(echo -n "$clean_text" | wc -c)

        i=1
        while [ $i -le "$length" ]; do
            char=$(echo "$clean_text" | cut -c $i)
            pos=$(awk -v c="$char" '
                BEGIN {
                    keysquare = "'"$keysquare"'"
                    for (i = 1; i <= length(keysquare); i++) {
                        if (substr(keysquare, i, 1) == c) {
                            row = int((i - 1) / 6)
                            col = (i - 1) % 6
                            printf("%d %d\n", row, col)
                            exit
                        }
                    }
                }')
            row=$(echo "$pos" | cut -d' ' -f1)
            col=$(echo "$pos" | cut -d' ' -f2)

            result="${result}$(echo "$symbols" | cut -c $((row + 1)))$(echo "$symbols" | cut -c $((col + 1)))"
            i=$((i + 1))
        done

        # Transposition Phase
        num_cols=$(echo -n "$key" | wc -c)
        column_order=$(echo "$key" | fold -w1 | nl -nln | sort -k2 | awk '{print $1}')

        transposed_result=""
        for col in $column_order; do
            pos=$((col - 1))
            while [ $pos -lt ${#result} ]; do
                transposed_result="${transposed_result}$(echo "$result" | cut -c $((pos + 1)))"
                pos=$((pos + num_cols))
            done
        done

        echo "$transposed_result"
elif [ "$mode" = "decrypt" ]; then
    # Validate ciphertext length and calculate dimensions
    length=$(printf "%s" "$clean_text" | wc -c)

    num_cols=$(printf "%s" "$key" | wc -c)
    num_rows=$(( (length + num_cols - 1) / num_cols ))

    # Normalize key
    key=$(echo "$key" | tr 'a-z' 'A-Z')

    # Generate column order based on the key
    column_order=$(printf "%s" "$key" | fold -w1 | nl -nln | sort -k2 | awk '{print $1}')

    # Reverse transpose ciphertext using awk
    reverse_result=$(printf "%s" "$clean_text" | awk -v order="$column_order" -v num_cols="$num_cols" -v text_length="$length" '
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
    symbols="ADFGVX"
    result=""
    i=1
    while [ "$i" -le "$length" ]; do
        pair=$(printf "%s" "$reverse_result" | cut -c "$i"-"$((i + 1))")
        symbol1=$(printf "%s" "$pair" | cut -c1)
        symbol2=$(printf "%s" "$pair" | cut -c2)

        case $symbol1 in
            A) row=0 ;;
            D) row=1 ;;
            F) row=2 ;;
            G) row=3 ;;
            V) row=4 ;;
            X) row=5 ;;
        esac

        case $symbol2 in
            A) col=0 ;;
            D) col=1 ;;
            F) col=2 ;;
            G) col=3 ;;
            V) col=4 ;;
            X) col=5 ;;
        esac

        index=$(( row * 6 + col ))
        mapped_char=$(echo "$keysquare" | cut -c $((index + 1)))

        result=$(printf "%s%s" "$result" "$mapped_char")
        i=$((i + 2))
    done

    printf "%s\n" "$result"
    else
        echo "Error: Invalid mode. Use 'encrypt' or 'decrypt'." >&2
        return 1
    fi
}




# Main script logic
usage() {
    echo "Usage: $0 -c cipher -m mode -t text [-s shift] [-a a] [-b b] [-k key] [-q keysquare]"
    echo "cipher: adfgvx, affine, atbash, beaufort, caesar, hill, nihilist, playfair, railfence, rot13, trithemius, or vigenere"
    echo "mode: encrypt or decrypt"
    echo "text: text to be encrypted or decrypted"
    echo "shift: shift value for Caesar Cipher (default: 3)"
    echo "a: multiplier value for Affine Cipher (default: 5)"
    echo "b: additive value for Affine Cipher (default: 8)"
    echo "key: key for Playfair, Vigenère, Railfence, ADFGVX, or Nihilist Ciphers"
    echo "keysquare: keysquare for ADFGVX Cipher"
    exit 1
}

while getopts ":c:m:t:s:a:b:k:q:" opt; do
    case "$opt" in
        a) a="$OPTARG" ;;
        b) b="$OPTARG" ;;
        c) cipher="$OPTARG" ;;
        k) key="$OPTARG" ;;
        m) mode="$OPTARG" ;;
        q) keysquare="$OPTARG" ;;  # Handle keysquare input
        s) shift="$OPTARG" ;;
        t) text="$OPTARG" ;;
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

# Dispatch cipher functions based on the provided cipher type
case "$cipher" in
    adfgvx) adfgvx_cipher "$text" "$key" "$mode" "$keysquare" ;;
    affine) affine_cipher "$text" "$a" "$b" "$mode" ;;
    atbash) atbash "$text" ;;
    beaufort) beaufort_cipher "$text" "$key" "$mode" ;;
    caesar) caesar_cipher "$text" "$shift" "$mode" ;;
    hill) hill_cipher "$text" "$key" "$mode" ;;
    nihilist) nihilist_cipher "$text" "$key" "$mode" ;;
    playfair) playfair_cipher "$text" "$key" "$mode" ;;
    railfence) railfence_cipher "$text" "$key" "$mode" ;;
    rot13) rot13 "$text" ;;
    trithemius) trithemius_cipher "$text" "$mode" ;;
    vigenere) vigenere_cipher "$text" "$key" "$mode" ;;
    *) usage ;;
esac
