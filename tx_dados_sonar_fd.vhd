library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity tx_dados_sonar_fd is
    port (
        clock: in std_logic;
        reset: in std_logic;
        transmite: in std_logic;
        recebe_dado: in std_logic;
        proximo: in std_logic;
        angulo2: in std_logic_vector(7 downto 0); -- digitos BCD
        angulo1: in std_logic_vector(7 downto 0); -- de angulo
        angulo0: in std_logic_vector(7 downto 0);
        distancia2: in std_logic_vector(3 downto 0); -- e de distancia
        distancia1: in std_logic_vector(3 downto 0);
        distancia0: in std_logic_vector(3 downto 0);
        entrada_serial: in std_logic;
        saida_serial: out std_logic;
        dado_recebido: out std_logic_vector (7 downto 0);
        fim: out std_logic;
        pronto_tx: out std_logic;
        pronto_rx: out std_logic;
		  db_dado_tx: out std_logic_vector (7 downto 0);
        db_estado_tx, db_estado_rx: out std_logic_vector (3 downto 0)
    );
end entity;

architecture tx_dados_sonar_fd_arch of tx_dados_sonar_fd is
     
    component mux_8x1_n
        generic (
            constant BITS: integer
        );
        port ( 
            D0 :     in  std_logic_vector (BITS-1 downto 0);
            D1 :     in  std_logic_vector (BITS-1 downto 0);
            D2 :     in  std_logic_vector (BITS-1 downto 0);
            D3 :     in  std_logic_vector (BITS-1 downto 0);
            D4 :     in  std_logic_vector (BITS-1 downto 0);
            D5 :     in  std_logic_vector (BITS-1 downto 0);
            D6 :     in  std_logic_vector (BITS-1 downto 0);
            D7 :     in  std_logic_vector (BITS-1 downto 0);
            SEL:     in  std_logic_vector (2 downto 0);
            MUX_OUT: out std_logic_vector (BITS-1 downto 0)
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

    component uart_8N2
        port (
            clock             : in  std_logic;
            reset             : in  std_logic;
            transmite_dado    : in  std_logic;
            dados_ascii       : in  std_logic_vector (7 downto 0);
            dado_serial       : in  std_logic;
            recebe_dado       : in  std_logic;
            saida_serial      : out std_logic;
            pronto_tx         : out std_logic;
            dado_recebido_rx  : out std_logic_vector (7 downto 0);
            tem_dado          : out std_logic;
            pronto_rx         : out std_logic;
            db_estado_tx      : out std_logic_vector (3 downto 0);
            db_estado_rx      : out std_logic_vector (3 downto 0);
            db_dado_tx        : out std_logic_vector (7 downto 0)
        );
    end component;
    
    signal s_angulo0, s_angulo1, s_angulo2, s_distancia0, s_distancia1, s_distancia2, s_virgula, s_ponto : std_logic_vector (7 downto 0);
    signal s_reset, s_transmite, s_fim, s_proximo, s_saida_serial, s_entrada_serial, s_recebe_dado, s_tem_dado : std_logic;
    signal s_posicao : std_logic_vector (2 downto 0);
    signal s_mux_out : std_logic_vector (7 downto 0);
	 signal s_dado_tx: std_logic_vector (7 downto 0);
    signal s_estado_tx, s_estado_rx : std_logic_vector (3 downto 0);

begin

    s_angulo0 <= angulo0;
    s_angulo1 <= angulo1;
    s_angulo2 <= angulo2;
    s_distancia0 <= "0011" & distancia0;
    s_distancia1 <= "0011" & distancia1;
    s_distancia2 <= "0011" & distancia2;
    s_virgula <= "00101100";
    s_ponto <= "00101110";

    s_reset <= reset;
    s_transmite <= transmite;
    s_proximo <= proximo;
    s_recebe_dado <= recebe_dado;
    s_entrada_serial <= entrada_serial;

    MUX: mux_8x1_n generic map (BITS => 8) port map (s_angulo0, s_angulo1, s_angulo2, s_virgula, s_distancia0, 
                                                     s_distancia1, s_distancia2, s_ponto, s_posicao, s_mux_out); 

    UART: uart_8N2 port map (clock, s_reset, s_transmite, s_mux_out, s_entrada_serial, s_recebe_dado,
                             s_saida_serial, pronto_tx, dado_recebido, s_tem_dado, pronto_rx, s_estado_tx, s_estado_rx, s_dado_tx);

    CONT: contadorg_m generic map (M => 8) port map (clock, s_reset, '0', s_proximo, s_posicao, s_fim, open);

    saida_serial <= s_saida_serial;
    fim <= s_fim;
    db_estado_tx <= s_estado_tx;
    db_estado_rx <= s_estado_rx;
    db_dado_tx <= s_dado_tx;
    
end architecture;