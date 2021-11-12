library ieee;
use ieee.std_logic_1164.all;

entity servo_uc is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        acionar     : in  std_logic;
        close_mid   : in  std_logic;
        close_end   : in  std_logic;
        lid_open    : out std_logic;
        reset_timer : out std_logic;
        count_mid   : out std_logic; -- sinal para o led de fechamento
        count_end   : out std_logic;
        estado_hex  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture servo_uc_arch of servo_uc is
    type tipo_estado is (fechado, timer, timer_acabando, timer_reset);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= fechado;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (acionar, close_mid, close_end, Eatual) 
    begin

      case Eatual is

        when fechado =>          if acionar='1' then Eprox <= timer;
                                 else                Eprox <= fechado;
                                 end if;

        when timer =>            if close_mid='1'  then Eprox <= timer_acabando;
                                 elsif acionar='1' then Eprox <= fechado;
                                 else                   Eprox <= timer;
                                 end if;

        when timer_acabando =>   if close_end='1'        then Eprox <= fechado;
                                 elsif acionar='1'       then Eprox <= timer_reset;
                                 else                         Eprox <= timer_acabando;
                                 end if;

        when timer_reset =>      Eprox <= timer;

        when others =>           Eprox <= fechado;

      end case;

    end process;

    -- logica de saida (Moore)
		  
	with Eatual select
        lid_open <= '0' when fechado, '1' when others;

    with Eatual select
        reset_timer <= '1' when fechado, '1' when timer_reset, '0' when others;

    with Eatual select
        count_mid <= '1' when timer, '0' when others;

    with Eatual select
        count_end <= '1' when timer_acabando, '0' when others;

    -- logica de estado para o debugger
    process (Eatual)
    begin
        case Eatual is
            when fechado => estado_hex <= "0000";
            when timer => estado_hex <= "0001";
            when timer_acabando => estado_hex <= "0010";
            when timer_reset => estado_hex <= "0011";
            when others => estado_hex <= "1111";
        end case;
    end process;


end architecture;