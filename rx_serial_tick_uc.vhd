library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_tick_uc is 
    port ( clock, reset, dado, tick, fim, recebe_dado:                       in  std_logic;
           zera, limpa, conta, carrega, desloca, pronto, registra, tem_dado: out std_logic;
           estado_hex:                                                       out std_logic_vector (3 downto 0)
    );
end entity;

architecture rx_serial_tick_uc_arch of rx_serial_tick_uc is

    type tipo_estado is (inicial, preparacao, espera, recepcao, armazena, final, dado_presente);
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
    process (dado, tick, fim, recebe_dado, Eatual) 
    begin

      case Eatual is

        when inicial =>          if dado='0' then Eprox <= preparacao;
                                 else             Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= espera;

        when espera =>           if tick='1' then   Eprox <= recepcao;
                                 elsif fim='0' then Eprox <= espera;
                                 else               Eprox <= armazena;
                                 end if;

        when recepcao =>         if fim='0' then Eprox <= espera;
                                 else            Eprox <= final;
                                 end if;
                                 
        when armazena =>         Eprox <= final;     
 
        when final =>            Eprox <= dado_presente;

        when dado_presente =>    if recebe_dado='0' then Eprox <= dado_presente;
                                 else                    Eprox <= inicial;
                                 end if;

        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        carrega <= '1' when preparacao, '0' when others;

    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        limpa <= '1' when preparacao, '0' when others;

    with Eatual select
        desloca <= '1' when recepcao, '0' when others;

    with Eatual select
        conta <= '1' when recepcao, '0' when others;

    with Eatual select
        registra <= '1' when armazena, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    with Eatual select
        tem_dado <= '1' when dado_presente, '0' when others;

    -- logica de estado para o debugger
    process (Eatual)
    begin
        case Eatual is
            when inicial => estado_hex <= "0000";
            when preparacao => estado_hex <= "0001";
            when espera => estado_hex <= "0010";
            when recepcao => estado_hex <= "0011";
            when armazena => estado_hex <= "0100";
            when final => estado_hex <= "0101";
            when dado_presente => estado_hex <= "0110";
            when others => estado_hex <= "1111";
        end case;
    end process;


end rx_serial_tick_uc_arch;
