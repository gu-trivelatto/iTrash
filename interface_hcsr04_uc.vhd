library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_uc is 
    port ( 
        clock, reset, medir, echo :            in  std_logic;
        conta, pronto, registra, gera, zera :  out std_logic;
        estado_hex :                           out std_logic_vector (3 downto 0)
    );
end entity;

architecture interface_hcsr04_uc_arch of interface_hcsr04_uc is

    type tipo_estado is (inicial, preparacao, trigger, espera_echo, medida, fim_medida);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (medir, echo, Eatual) 
    begin

      case Eatual is

        when inicial =>          if medir='1' then Eprox <= preparacao;
                                 else              Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= trigger;

        when trigger =>          Eprox <= espera_echo;

        when espera_echo =>      if echo='1' then   Eprox <= medida;
                                 else               Eprox <= espera_echo;
                                 end if;

        when medida =>           if echo='0' then Eprox <= fim_medida;
                                 else             Eprox <= medida;
                                 end if;
                                 
        when fim_medida =>       Eprox <= inicial;

        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        zera <= '1' when preparacao, '0' when others;
    
    with Eatual select
        gera <= '1' when trigger, '0' when others;

    with Eatual select
        conta <= '1' when medida, '0' when others;

    with Eatual select
        registra <= '1' when fim_medida, '0' when others;

    with Eatual select
        pronto <= '1' when fim_medida, '0' when others;

    -- logica de estado para o debugger
    process (Eatual)
    begin
        case Eatual is
            when inicial => estado_hex <= "0000";
            when preparacao => estado_hex <= "0001";
            when trigger => estado_hex <= "0010";
            when espera_echo => estado_hex <= "0011";
            when medida => estado_hex <= "0100";
            when fim_medida => estado_hex <= "0101";
            when others => estado_hex <= "1111";
        end case;
    end process;


end interface_hcsr04_uc_arch;
