library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;


entity rx_serial_8N2 is
    port (
        clock, reset, dado_serial : in  std_logic;
        recebe_dado :               in  std_logic;
        dado_recebido :             out std_logic_vector (7 downto 0);
        pronto_rx, tem_dado :       out std_logic;
        db_estado :                 out std_logic_vector (3 downto 0)
    );
end entity;

architecture rx_serial_8N2_arch of rx_serial_8N2 is
     
    component rx_serial_tick_uc port ( 
            clock, reset, dado, tick, fim, recebe_dado: in  std_logic;
            zera, limpa, conta, carrega, desloca, pronto, registra, tem_dado: out std_logic ;
            estado_hex: out std_logic_vector (3 downto 0)
    );
    end component;

    component rx_serial_8N2_fd port (
        clock, reset, limpa, registra: in std_logic;
        zera, conta, carrega, desloca: in std_logic;
        entrada_serial: in std_logic;
        dados_ascii: out std_logic_vector (7 downto 0);
        fim : out std_logic;
        db_dado_decimal, db_dado_unidade: out std_logic_vector (6 downto 0)
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
    
    signal s_reset, s_limpa, s_registra, s_dado_serial, s_zera : std_logic;
    signal s_conta, s_carrega, s_desloca, s_tick, s_fim, s_recebe_dado: std_logic;
    signal s_db_estado : std_logic_vector (3 downto 0);

begin

    -- sinais mapeados na GPIO (ativos em alto)
    s_reset         <= reset;
    s_recebe_dado   <= recebe_dado;
    s_dado_serial   <= dado_serial;

    -- unidade de controle
    U1_UC: rx_serial_tick_uc port map (clock, s_reset, s_dado_serial, s_tick, s_fim, s_recebe_dado, s_zera, s_limpa,
                                       s_conta, s_carrega, s_desloca, pronto_rx, s_registra, tem_dado, s_db_estado);

    -- fluxo de dados
    U2_FD: rx_serial_8N2_fd port map (clock, s_reset, s_limpa, s_registra, s_zera, s_conta, s_carrega, s_desloca, 
                                      s_dado_serial, dado_recebido, s_fim, open, open);

    -- gerador de tick
    -- fator de divisao 50MHz para 9.600 bauds (5208=50M/9600)
    U3_TICK: contadorg_m generic map (M => 5208) port map (clock, s_zera, s_zera, '1', open, open, s_tick);

    db_estado <= s_db_estado;
    
end architecture;

