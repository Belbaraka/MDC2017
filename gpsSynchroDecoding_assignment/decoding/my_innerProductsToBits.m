function decodedBits = my_innerProductsToBits(bitwiseInnerProductResults)
%INNERPRODUCTSTOBITS Make hard decisions about the transmitted bits.
%   DECODEDBITS = INNERPRODUCTSTOBITS(BITWISEINNERPRODUCTRESULTS) Returns
%   in DECODEDBITS a vector of the same dimensions as BITWISEINNERPRODUCTS
%   with the hard decisions about the transmitted bits. The elements of
%   DECODEDBITS are 1 or -1.

L=length(bitwiseInnerProductResults);

%initialize the decoded bits vector
decodedBits=zeros(1,L);

%we set the first bit to 1
decodedBits(1)=1;

IP1=bitwiseInnerProductResults(1);

for i=2:L
    IP2=bitwiseInnerProductResults(i);
    angle=phase(IP1*conj(IP2));
    if angle>3*pi/4 || angle <-3*pi/4
        decodedBits(i)=-decodedBits(i-1);
    else
        decodedBits(i)=decodedBits(i-1);
    end
    IP1=IP2;
end
end