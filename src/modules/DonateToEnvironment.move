address 0x040B76e04c4E6c523f8e096781ad7044 {
    module DonateToEnvironment{

        use 0x1::Signer;
        use 0x1::NFT;
        use 0x1::Account;
        use 0x1::NFTGallery;


        struct Shared_Cap has key,store{
            cap :      NFT::MintCapability<META>,
        }
        struct META has key,drop,store,copy{
            Count:  u128
        }
        struct BODY has key,drop,store,copy{

        }
        public fun  initAddress():address{
            return @0x040B76e04c4E6c523f8e096781ad7044
        }      

        public fun init(account:&signer) {
            let addr = Signer::address_of(account);
            assert( addr == initAddress() , 10001);
            assert( !exists<Shared_Cap> ( initAddress() ) , 10002 );
            NFT::register_v2<META>(account,NFT::new_meta(b"donation certificate",b"Thank you for your contribution to the world's environmental protection public welfare activities"));
            let nft_cap    = NFT::remove_mint_capability<META>(account);
            move_to(account, Shared_Cap { cap:nft_cap } );
            
        }
        public fun Donation (account:&signer,amount:u128) acquires Shared_Cap {
            let addr = Signer::address_of(account);
            let cap = borrow_global_mut<Shared_Cap>(initAddress());
            let balance = Account::balance<0x1::STC::STC>(addr);
            assert(balance >= amount , 10003);
            Account::pay_from<0x1::STC::STC>(account,initAddress(),amount);
            let nft = NFT::mint_with_cap_v2<META,BODY>(addr,&mut cap.cap,NFT::new_meta(b"RandomNumberGeneratorFlag",b"Random numbers can be obtained by burning this NFT after a specified time"),META{Count:balance},BODY{});
            
            NFTGallery::accept<META, BODY>(account);
            NFTGallery::deposit<META, BODY>(account,nft);
        }
    }

    module DonateToEnvironment_Script{
        use 0x040B76e04c4E6c523f8e096781ad7044::DonateToEnvironment;
        public (script) fun Donation(account:signer,amount:u128){
            DonateToEnvironment::Donation(&account,amount);
        }
        public (script) fun init(account:signer){
            DonateToEnvironment::init(&account);
        }
    }

}
