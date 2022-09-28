-module(playgroung).

-export([start/0]).


start() -> 
    Random = (base64:encode_to_string(crypto:strong_rand_bytes(20))),
    UFID =
        "gupta.raghav",
    RString = string:concat(UFID,Random),
    <<Hashed:256>> = crypto:hash(sha256, RString),
    HashStr = string:right(integer_to_list(Hashed,16),64,$0),
    LHashStr = string:to_lower(HashStr).


















    % Random = "asdnansd",
    % UFID =
    %     "gupta.raghav",
    % Rstring = binary_to_list(
    %     re:replace(Random, "\\W", "", [
    %         global, {return, binary}
    %     ])
    % ),
    % Bhstring = string:concat(UFID, Random),
    % Ahstring = io_lib:format("~64.16.0b", [
    %     binary:decode_unsigned(
    %         crypto:hash(
    %             sha256,
    %             Bhstring
    %         )
    %     )
    % ]),
    % <<Integer:256>> = crypto:hash(sha256, Ahstring),
    % Hashed = io_lib:format("~64.16.0b", [Integer]),
    % Hashed.    
