library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;


entity interface_hcsr04 is
    port (
        clock, reset, medir :          in  std_logic;
        echo :                         in  std_logic;
        trigger :                      out std_logic;
        medida :                       out std_logic_vector (11 downto 0);
        pronto :                       out std_logic;
        db_estado :                    out std_logic_vector (3 downto 0)
    );
end entity;

architecture interface_hcsr04_arch of interface_hcsr04 is
     
    component interface_hcsr04_uc port ( 
            clock, reset, medir, echo :           in  std_logic;
            conta, pronto, registra, gera, zera : out std_logic;
            estado_hex :                          out std_logic_vector (3 downto 0)
    );
    end component;

    component interface_hcsr04_fd port (
            clock, zera, conta : in  std_logic;
            registra, gera :     in  std_logic;
            distancia :          out std_logic_vector (11 downto 0);
            fim, trigger :       out std_logic;
            db_trigger :         out std_logic
    );
    end component;
    
    component edge_detector is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;
    
    signal s_reset, s_registra, s_zera, s_echo : std_logic;
    signal s_conta, s_gera, s_trigger : std_logic;
    signal s_medida : std_logic_vector (11 downto 0);

begin

    -- sinais mapeados na GPIO (ativos em alto)
    s_reset  <= reset;
    s_echo   <= echo;

    -- unidade de controle
    U1_UC: interface_hcsr04_uc port map (clock, s_reset, medir, s_echo, s_conta,
                                         pronto, s_registra, s_gera, s_zera, db_estado);

    -- fluxo de dados
    U2_FD: interface_hcsr04_fd port map (clock, s_zera, s_conta, s_registra, s_gera, 
                                         s_medida, open, s_trigger);

    trigger <= s_trigger;
    medida <= s_medida;
    
end architecture;

