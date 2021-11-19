library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity interface_hcsr04_fd is
    port (
        clock, zera, conta : in  std_logic;
        registra, gera :     in  std_logic;
        distancia :          out std_logic_vector (11 downto 0);
        fim, trigger :       out std_logic;
        db_trigger :         out std_logic
    );
end entity;

architecture interface_hcsr04_fd_arch of interface_hcsr04_fd is

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

    component contador_bcd_4digitos
    port (
        clock, zera, conta : in std_logic;
        dig3, dig2, dig1, dig0 : out std_logic_vector (3 downto 0);
        fim : out std_logic
    );
    end component;

    component gerador_pulso
        generic (
           largura: integer
        );
        port(
           clock:  in  std_logic;
           reset:  in  std_logic;
           gera:   in  std_logic;
           para:   in  std_logic;
           pulso:  out std_logic;
           pronto: out std_logic
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
    
    signal s_conta_1cm: std_logic;
    signal s_distancia: std_logic_vector (11 downto 0);
    signal s_dig3, s_dig2, s_dig1, s_dig0 : std_logic_vector (3 downto 0);

begin 

    s_distancia <= s_dig2 & s_dig1 & s_dig0;

    U1: contador_bcd_4digitos port map (clock, zera, s_conta_1cm, s_dig3, s_dig2, s_dig1, s_dig0, fim);

    U2: contadorg_m generic map (M => 2941) port map (clock, zera, zera, conta, open, s_conta_1cm, open);

    U3: registrador_n generic map (N => 12) port map (clock, zera, registra, s_distancia, distancia);

    U4: gerador_pulso generic map (largura => 500)port map (clock, zera, gera, '0', trigger, open);
    
end architecture;

