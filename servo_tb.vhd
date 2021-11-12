-- controle_servo_tb
--
library ieee;
use ieee.std_logic_1164.all;

entity servo_tb is
end entity;

architecture tb of servo_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component servo is
    port (
      clock       : in  std_logic;
      reset       : in  std_logic;
      acionar     : in  std_logic;
      pwm         : out std_logic;
      closing_led : out std_logic
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal acionar_in: std_logic := '0';
  signal pwm_out: std_logic := '0';
  signal closing_led_out: std_logic := '0';


  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod: time := 20 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

 
  -- Conecta DUT (Device Under Test)
  dut: servo port map( 
         clock=>       clock_in,
         reset=>       reset_in,
         acionar=>     acionar_in,
         pwm=>         pwm_out,
         closing_led=> closing_led_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" & LF & "... Simulacao ate 500 ms. Aguarde o final da simulacao..." severity note;
    keep_simulating <= '1';
    
    ---- inicio: reset ----------------
    reset_in <= '1'; 
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ---- casos de teste
    -- fechado
    acionar_in <= '0'; -- largura de pulso de 1ms
    wait for 200 ms;

    -- aberto
    acionar_in <= '1'; -- largura de pulso de 2ms
    wait for 100 ms;
    acionar_in <= '0';
    wait for 200 ms;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;