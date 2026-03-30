#!/bin/sh
# ccipher-tui.sh - Pure POSIX Text User Interface for ccipher
# A graphical terminal interface for classical ciphers

# ANSI escape codes for colors and formatting
ESC='\033'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"
BG_BLUE="${ESC}[44m"
BG_CYAN="${ESC}[46m"

# Terminal dimensions
ROWS=24
COLS=80

# Initialize terminal
init_term() {
    # Try to get terminal dimensions
    if command -v stty >/dev/null 2>&1; then
        ROWS=$(stty size 2>/dev/null | cut -d' ' -f1)
        COLS=$(stty size 2>/dev/null | cut -d' ' -f2)
    fi
    [ -z "$ROWS" ] && ROWS=24
    [ -z "$COLS" ] && COLS=80
    
    # Clear screen and hide cursor
    printf "${ESC}[2J${ESC}[H${ESC}[?25l"
}

# Restore terminal
restore_term() {
    printf "${RESET}${ESC}[?25h${ESC}[2J${ESC}[H"
}

# Clear screen
clear_screen() {
    printf "${ESC}[2J${ESC}[H"
}

# Move cursor
move_cursor() {
    printf "${ESC}[${1};${2}H"
}

# Draw box
draw_box() {
    local row=$1
    local col=$2
    local width=$3
    local height=$4
    local title="$5"
    
    local i
    
    # Top border
    move_cursor $row $col
    printf "${CYAN}┌"
    for i in $(seq 1 $((width - 2))); do printf "─"; done
    printf "┐${RESET}"
    
    # Title
    if [ -n "$title" ]; then
        move_cursor $row $((col + 2))
        printf "${BOLD}${WHITE} %s ${RESET}" "$title"
    fi
    
    # Sides
    local j
    for j in $(seq 1 $((height - 2))); do
        move_cursor $((row + j)) $col
        printf "${CYAN}│${RESET}"
        move_cursor $((row + j)) $((col + width - 1))
        printf "${CYAN}│${RESET}"
    done
    
    # Bottom border
    move_cursor $((row + height - 1)) $col
    printf "${CYAN}└"
    for i in $(seq 1 $((width - 2))); do printf "─"; done
    printf "┘${RESET}"
}

# Center text
center_text() {
    local text="$1"
    local width="$2"
    local padding=$(( (width - ${#text}) / 2 ))
    [ $padding -lt 0 ] && padding=0
    printf "%*s%s%*s" $padding "" "$text" $((width - padding - ${#text})) ""
}

# Draw header
draw_header() {
    clear_screen
    draw_box 1 1 $COLS 3 "CCIPHER - Classical Cipher Suite"
    move_cursor 2 3
    center_text "POSIX Shell Implementation" $((COLS - 4))
}

# Draw menu
draw_menu() {
    local start_row=$1
    local title="$2"
    shift 2
    local items="$*"  # Space-separated list
    local count=$(echo "$items" | wc -w)
    local height=$((count + 4))
    local width=$COLS
    
    draw_box $start_row 1 $width $height "$title"
    
    local i=1
    local item
    for item in $items; do
        move_cursor $((start_row + 1 + i)) 3
        printf "  ${DIM}%2d${RESET}  %s" "$i" "$item"
        i=$((i + 1))
    done
    
    move_cursor $((start_row + height - 1)) 3
    printf "${DIM}Press number to select, 'q' to quit${RESET}"
}

# Get single key press
get_key() {
    local key
    # Set terminal to raw mode for single char read
    stty -echo -icanon min 1 time 0 2>/dev/null
    key=$(dd bs=1 count=1 2>/dev/null)
    stty echo icanon 2>/dev/null
    printf '%s' "$key"
}

# Input field
input_field() {
    local prompt="$1"
    local default="$2"
    local value
    
    move_cursor $current_row 3
    printf "${WHITE}%s${RESET}: " "$prompt"
    [ -n "$default" ] && printf "${DIM}[%s]${RESET} " "$default"
    
    # Show cursor and read input
    printf "${ESC}[?25h"
    read -r value
    printf "${ESC}[?25l"
    
    # Return default if empty
    [ -z "$value" ] && [ -n "$default" ] && value="$default"
    
    printf '%s' "$value"
}

# Cipher categories
CIPHER_NAMES="caesar|rot13|atbash|affine|simple|substitution"
CIPHER_NAMES="$CIPHER_NAMES|vigenere|autokey|beaufort|gronsfeld|porta|trithemius"
CIPHER_NAMES="$CIPHER_NAMES|polybius|nihilist|adfgvx"
CIPHER_NAMES="$CIPHER_NAMES|railfence|columnar"
CIPHER_NAMES="$CIPHER_NAMES|playfair|foursquare|bifid"
CIPHER_NAMES="$CIPHER_NAMES|hill|bacon|vic"

# Get cipher parameters
get_params() {
    local cipher="$1"
    
    current_row=5
    
    case "$cipher" in
        caesar)
            SHIFT=$(input_field "Shift value (1-25)" "3")
            PARAMS="-s $SHIFT"
            ;;
        affine)
            A_VAL=$(input_field "Multiplier 'a' (must be coprime to 26)" "5")
            B_VAL=$(input_field "Additive 'b'" "8")
            PARAMS="-a $A_VAL -b $B_VAL"
            ;;
        simple|substitution)
            KEY=$(input_field "Keyword" "SECRETKEY")
            PARAMS="-k $KEY"
            ;;
        vigenere|autokey|beaufort|porta)
            KEY=$(input_field "Keyword" "KEY")
            PARAMS="-k $KEY"
            ;;
        gronsfeld)
            KEY=$(input_field "Numeric key" "31415")
            PARAMS="-k $KEY"
            ;;
        polybius|nihilist)
            PARAMS=""
            ;;
        adfgvx)
            echo ""
            printf "${YELLOW}Note: ADFGVX requires a 36-character keysquare${RESET}\n"
            printf "A random one will be generated if not provided.\n"
            KEY=$(input_field "Keyword" "KEYWORD")
            KEYREQ=$(input_field "Keysquare (or press Enter to generate)" "")
            if [ -n "$KEYREQ" ]; then
                PARAMS="-k $KEY -q $KEYREQ"
            else
                PARAMS="-k $KEY"
            fi
            ;;
        railfence)
            RAILS=$(input_field "Number of rails" "3")
            PARAMS="-k $RAILS"
            ;;
        columnar)
            KEY=$(input_field "Keyword (letters for column order)" "ZEBRA")
            PARAMS="-k $KEY"
            ;;
        playfair)
            KEY=$(input_field "Keyword" "SECRETKEY")
            PARAMS="-k $KEY"
            ;;
        foursquare)
            KEY1=$(input_field "First keyword" "KEY1")
            KEY2=$(input_field "Second keyword" "KEY2")
            PARAMS="-k $KEY1 -2 $KEY2"
            ;;
        bifid)
            KEY=$(input_field "Keyword" "KEY")
            PARAMS="-k $KEY"
            ;;
        hill)
            printf "${YELLOW}Note: Hill cipher requires a numeric key matrix${RESET}\n"
            printf "For 2x2 matrix: 4 numbers (e.g., '3 2 5 7')${RESET}\n"
            printf "Matrix must have determinant coprime to 26.${RESET}\n"
            KEY=$(input_field "Matrix elements (space-separated)" "3 2 5 7")
            PARAMS="-k $KEY"
            ;;
        vic)
            printf "${YELLOW}VIC Cipher - Soviet Cold War cipher${RESET}\n"
            printf "Requires:\n"
            printf "  - Keyphrase (20+ characters)\n"
            printf "  - Date (6 digits, e.g., 071177)\n"
            printf "  - Personal number (1-2 digits)\n"
            printf "  - Indicator (5 random digits)\n"
            KEY=$(input_field "Keyphrase (20+ chars)" "THISISAVERYLONGKEYPHRASE")
            DATE=$(input_field "Date (6 digits)" "071177")
            PERS=$(input_field "Personal number" "8")
            IND=$(input_field "Indicator (5 digits)" "12345")
            PARAMS="-k $KEY -d $DATE -p $PERS -i $IND"
            ;;
        *)
            PARAMS=""
            ;;
    esac
}

# Show result screen
show_result() {
    local mode="$1"
    local cipher="$2"
    local input="$3"
    local output="$4"
    
    clear_screen
    draw_box 1 1 $COLS 7 "Result"
    
    move_cursor 3 3
    printf "${BOLD}Cipher:${RESET} %s" "$cipher"
    move_cursor 4 3
    printf "${BOLD}Mode:${RESET}   %s" "$mode"
    move_cursor 5 3
    printf "${BOLD}Input:${RESET}  %s" "$input"
    move_cursor 6 3
    printf "${BOLD}Output:${RESET} "
    
    # Handle long output
    if [ ${#output} -gt 60 ]; then
        printf "${GREEN}%s${RESET}" "$(echo "$output" | fold -w 70 | head -5)"
    else
        printf "${GREEN}%s${RESET}" "$output"
    fi
    
    move_cursor 9 1
    printf "${DIM}Copy output to clipboard? [y/N]${RESET} "
    
    # Show cursor for input
    printf "${ESC}[?25h"
    read -r copy_choice
    printf "${ESC}[?25l"
    
    case "$copy_choice" in
        y|Y)
            # Try various clipboard methods
            if command -v pbcopy >/dev/null 2>&1; then
                printf '%s' "$output" | pbcopy
                printf "${GREEN}Copied to clipboard (macOS)${RESET}\n"
            elif command -v xclip >/dev/null 2>&1; then
                printf '%s' "$output" | xclip -selection clipboard
                printf "${GREEN}Copied to clipboard (X11)${RESET}\n"
            elif command -v xsel >/dev/null 2>&1; then
                printf '%s' "$output" | xsel --clipboard --input
                printf "${GREEN}Copied to clipboard (X11)${RESET}\n"
            else
                printf "${YELLOW}Clipboard not available. Output:${RESET}\n"
                printf "%s\n" "$output"
            fi
            ;;
    esac
    
    printf "\n${DIM}Press Enter to continue...${RESET}"
    read -r dummy
}

# Run cipher
run_cipher() {
    local mode="$1"
    local cipher="$2"
    local text="$3"
    local params="$4"
    
    # Show processing message
    move_cursor $current_row 3
    printf "${DIM}Processing...${RESET}"
    
    # Run ccipher
    RESULT=$(./ccipher.sh -c "$cipher" -m "$mode" -t "$text" $params 2>&1)
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -ne 0 ]; then
        printf "\n${RED}Error: %s${RESET}\n" "$RESULT"
        printf "${DIM}Press Enter to continue...${RESET}"
        read -r dummy
        return 1
    fi
    
    return 0
}

# Input screen
input_screen() {
    local mode="$1"
    local cipher="$2"
    
    clear_screen
    draw_box 1 1 $COLS 5 "$cipher ($mode)"
    
    move_cursor 3 3
    printf "${WHITE}Enter text to ${mode}:${RESET}"
    
    current_row=6
    
    # Get text input
    move_cursor 6 3
    printf "${ESC}[?25h"
    printf "> "
    read -r TEXT
    printf "${ESC}[?25l"
    
    [ -z "$TEXT" ] && return 1
    
    # Get cipher-specific parameters
    get_params "$cipher"
    
    # Run the cipher
    run_cipher "$mode" "$cipher" "$TEXT" "$PARAMS"
    if [ $? -eq 0 ]; then
        show_result "$mode" "$cipher" "$TEXT" "$RESULT"
    fi
}

# Mode selection screen
mode_screen() {
    local cipher="$1"
    
    while true; do
        clear_screen
        draw_box 1 1 $COLS 6 "Select Mode"
        
        move_cursor 3 3
        printf "  ${GREEN}1${RESET}  Encrypt"
        move_cursor 4 3
        printf "  ${GREEN}2${RESET}  Decrypt"
        move_cursor 5 3
        printf "  ${DIM}Cipher: ${BOLD}%s${RESET}" "$cipher"
        
        move_cursor 8 1
        printf "${DIM}Select mode (1-2), or 'b' to go back, 'q' to quit${RESET}\n"
        printf "> "
        
        printf "${ESC}[?25h"
        read -r choice
        printf "${ESC}[?25l"
        
        case "$choice" in
            1|E|e|encrypt) input_screen "encrypt" "$cipher"; return $? ;;
            2|D|d|decrypt) input_screen "decrypt" "$cipher"; return $? ;;
            b|B) return 0 ;;
            q|Q) restore_term; exit 0 ;;
            *) printf "${RED}Invalid choice${RESET}\n"; sleep 1 ;;
        esac
    done
}

# Main menu
main_menu() {
    local choice
    
    while true; do
        draw_header
        
        # Cipher categories
        local items=""
        
        draw_box 5 1 $COLS 20 "Cipher Categories"
        
        move_cursor 7 3
        printf "${WHITE} 1.${RESET} Substitution    ${DIM}(Caesar, ROT13, Atbash, Affine, Simple)${RESET}"
        move_cursor 8 3
        printf "${WHITE} 2.${RESET} Polyalphabetic  ${DIM}(Vigenère, Autokey, Beaufort, Gronsfeld, Porta, Trithemius)${RESET}"
        move_cursor 9 3
        printf "${WHITE} 3.${RESET} Polybius Square ${DIM}(Polybius, Nihilist, ADFGVX)${RESET}"
        move_cursor 10 3
        printf "${WHITE} 4.${RESET} Transposition    ${DIM}(Rail Fence, Columnar)${RESET}"
        move_cursor 11 3
        printf "${WHITE} 5.${RESET} Bigraphic        ${DIM}(Playfair, Four-Square, Bifid)${RESET}"
        move_cursor 12 3
        printf "${WHITE} 6.${RESET} Matrix           ${DIM}(Hill)${RESET}"
        move_cursor 13 3
        printf "${WHITE} 7.${RESET} Steganographic   ${DIM}(Bacon)${RESET}"
        move_cursor 14 3
        printf "${WHITE} 8.${RESET} Complex          ${DIM}(VIC)${RESET}"
        move_cursor 15 3
        printf "${WHITE} 9.${RESET} Monoalphabetic   ${DIM}(Substitution)${RESET}"
        
        move_cursor 17 3
        printf "${WHITE}10.${RESET} List All Ciphers"
        
        move_cursor 20 3
        printf "${DIM}Select category (1-10), or 'q' to quit${RESET}"
        move_cursor 21 3
        printf "> "
        
        printf "${ESC}[?25h"
        read -r choice
        printf "${ESC}[?25l"
        
        case "$choice" in
            1) cipher_submenu "substitution" "caesar|rot13|atbash|affine|simple" ;;
            2) cipher_submenu "polyalphabetic" "vigenere|autokey|beaufort|gronsfeld|porta|trithemius" ;;
            3) cipher_submenu "polybius" "polybius|nihilist|adfgvx" ;;
            4) cipher_submenu "transposition" "railfence|columnar" ;;
            5) cipher_submenu "bigraphic" "playfair|foursquare|bifid" ;;
            6) cipher_submenu "matrix" "hill" ;;
            7) cipher_submenu "steganographic" "bacon" ;;
            8) cipher_submenu "complex" "vic" ;;
            9) cipher_submenu "monoalphabetic" "substitution" ;;
            10) list_all_ciphers ;;
            q|Q) restore_term; exit 0 ;;
            *) invalid_choice ;;
        esac
    done
}

# Cipher submenu
cipher_submenu() {
    local category="$1"
    local ciphers="$2"
    local choice
    local i
    
    while true; do
        clear_screen
        draw_box 1 1 $COLS 8 "$category Ciphers"
        
        # Convert pipe-separated to numbered list
        i=1
        OLDIFS="$IFS"
        IFS='|'
        for cipher in $ciphers; do
            move_cursor $((3 + i)) 3
            printf "  ${GREEN}%2d${RESET}  %s" "$i" "$cipher"
            i=$((i + 1))
        done
        IFS="$OLDIFS"
        
        move_cursor $((4 + i)) 3
        printf "${DIM}Select cipher (1-%d), or 'b' to go back, 'q' to quit${RESET}" $((i - 1))
        printf "\n> "
        
        printf "${ESC}[?25h"
        read -r choice
        printf "${ESC}[?25l"
        
        # Handle choice
        case "$choice" in
            b|B) return 0 ;;
            q|Q) restore_term; exit 0 ;;
            *)
                # Get cipher name by number
                i=1
                IFS='|'
                for cipher in $ciphers; do
                    if [ "$i" = "$choice" ]; then
                        IFS="$OLDIFS"
                        mode_screen "$cipher"
                        break 2
                    fi
                    i=$((i + 1))
                done
                IFS="$OLDIFS"
                printf "${RED}Invalid choice${RESET}\n"
                sleep 1
                ;;
        esac
    done
}

# List all ciphers
list_all_ciphers() {
    local ciphers="caesar rot13 atbash affine simple substitution vigenere autokey beaufort gronsfeld porta trithemius polybius nihilist adfgvx railfence columnar playfair foursquare bifid hill bacon vic"
    
    clear_screen
    draw_box 1 1 $COLS 23 "All Available Ciphers"
    
    local row=3
    local col=3
    
    for cipher in $ciphers; do
        move_cursor $row $col
        printf "  %-14s" "$cipher"
        col=$((col + 17))
        if [ $col -gt 60 ]; then
            col=3
            row=$((row + 1))
        fi
    done
    
    move_cursor 20 3
    printf "${DIM}Press Enter to return...${RESET}"
    printf "${ESC}[?25h"
    read -r dummy
    printf "${ESC}[?25l"
}

# Invalid choice handler
invalid_choice() {
    move_cursor 22 3
    printf "${RED}Invalid choice. Please try again.${RESET}"
    sleep 1
}

# Help screen
show_help() {
    clear_screen
    draw_box 1 1 $COLS 22 "Help - Keyboard Shortcuts"
    
    move_cursor 3 3
    printf "  ${WHITE}Numbers${RESET}    Select menu option"
    move_cursor 4 3
    printf "  ${WHITE}b/B${RESET}        Go back to previous menu"
    move_cursor 5 3
    printf "  ${WHITE}q/Q${RESET}        Quit the application"
    move_cursor 6 3
    printf "  ${WHITE}Enter${RESET}     Confirm selection"
    
    move_cursor 8 3
    printf "${WHITE}Supported Ciphers:${RESET}"
    move_cursor 9 3
    printf "  Substitution:   caesar, rot13, atbash, affine, simple"
    move_cursor 10 3
    printf "  Polyalphabetic: vigenere, autokey, beaufort, gronsfeld, porta, trithemius"
    move_cursor 11 3
    printf "  Polybius:       polybius, nihilist, adfgvx"
    move_cursor 12 3
    printf "  Transposition:  railfence, columnar"
    move_cursor 13 3
    printf "  Bigraphic:      playfair, foursquare, bifid"
    move_cursor 14 3
    printf "  Matrix:         hill"
    move_cursor 15 3
    printf "  Steganographic: bacon"
    move_cursor 16 3
    printf "  Complex:        vic (Soviet cipher)"
    
    move_cursor 18 3
    printf "${WHITE}For more info:${RESET} See README.md"
    
    move_cursor 21 3
    printf "${DIM}Press Enter to return...${RESET}"
    read -r dummy
}

# Main entry point
main() {
    #trap restore_term EXIT INT TERM
    
    init_term
    
    # Check if ccipher.sh exists
    if [ ! -f "./ccipher.sh" ]; then
        printf "${RED}Error: ccipher.sh not found in current directory${RESET}\n"
        printf "Please run this script from the ccipher directory.\n"
        restore_term
        exit 1
    fi
    
    main_menu
    restore_term
}

# Run main
main "$@"