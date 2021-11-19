library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity rx_serial_8N2_fd is
    port (
        clock, reset, limpa, registra: in  std_logic;
        zera, conta, carrega, desloca: in  std_logic;
        entrada_serial:                in  std_logic;
        dados_ascii:                   out std_logic_vector (7 downto 0);
        fim:                           out std_logic;
        -- dados de debuging
        db_dado_decimal, db_dado_unidade: out std_logic_vector (6 downto 0)
    );
end entity;

architecture rx_serial_8N2_fd_arch of rx_serial_8N2_fd is
     
    component deslocador_n
    generic (
        constant N: integer 
    );
    port (
        clock, reset: in std_logic;
        carrega, desloca, entrada_serial: in std_logic; 
        dados: in std_logic_vector (N-1 downto 0);
        saida: out  std_logic_vector (N-1 downto 0)
    );
    end component;

    component contadorg_m
    generic (
        constant M: integer
    );
    port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic
    );
    end component;

    component registrador_n
    generic (
        constant N: integer
    );
    port (
        clock, clear, enable: in std_logic;
        D: in std_logic_vector (N-1 downto 0);
        Q: out std_logic_vector (N-1 downto 0)
    );
    end component;

    component hex7seg is port (
        hexa: in std_logic_vector (3 downto 0);
        sseg: out std_logic_vector (6 downto 0)
    );
    end component;
    
    signal s_full_word: std_logic_vector (10 downto 0);
    signal s_saida: std_logic_vector (10 downto 0);

begin 

    U1: deslocador_n generic map (N => 11) port map (clock, reset, carrega, desloca, entrada_serial, "00000000000", s_full_word);

    U2: contadorg_m generic map (M => 12) port map (clock, zera, zera, conta, open, fim, open);

    U3: registrador_n generic map (N => 11) port map (clock, zera, registra, s_full_word, s_saida);

    -- conversor de 7 segmentos para a parte decimal do sinal de saida
    U4_SSEG: hex7seg port map (s_saida(8 downto 5), db_dado_decimal);

    -- conversor de 7 segmentos para a parte unitária do sinal de saida
    U5_SSEG: hex7seg port map (s_saida(4 downto 1), db_dado_unidade);

    dados_ascii <= s_saida(8 downto 1);
    
end architecture;

