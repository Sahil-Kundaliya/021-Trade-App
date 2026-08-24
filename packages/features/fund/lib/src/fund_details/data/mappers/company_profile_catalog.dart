import '../../domain/entities/fund_details.dart';

abstract final class CompanyProfileCatalog {
  static CompanyProfile forFund({
    required String symbol,
    required String companyName,
  }) {
    final underlying = symbol.split(' ').first.toUpperCase();
    return _profiles[underlying] ??
        CompanyProfile(
          legalName: companyName,
          industry: 'Listed Company',
          registeredOffice: 'Registered office information unavailable',
          corporateIdentityNumber: 'Not available',
          website: 'Not available',
          email: 'Not available',
          phone: 'Not available',
          directors: const [],
          management: const [],
        );
  }
}

const _profiles = <String, CompanyProfile>{
  'RELIANCE': CompanyProfile(
    legalName: 'Reliance Industries Limited',
    industry: 'Diversified Industries',
    registeredOffice:
        'Maker Chambers IV, 3rd Floor, 222 Nariman Point, Mumbai, Maharashtra 400021',
    corporateIdentityNumber: 'L17110MH1973PLC019786',
    website: 'www.ril.com',
    email: 'investor.relations@ril.com',
    phone: '+91 22 3555 5000',
    directors: [
      CompanyPerson(name: 'Mukesh D. Ambani', role: 'Chairman & MD'),
      CompanyPerson(name: 'Hital R. Meswani', role: 'Executive Director'),
      CompanyPerson(name: 'Nikhil R. Meswani', role: 'Executive Director'),
    ],
    management: [
      CompanyPerson(name: 'Mukesh D. Ambani', role: 'Chairman & MD'),
      CompanyPerson(name: 'P. M. S. Prasad', role: 'Executive Director'),
      CompanyPerson(name: 'V. Srikanth', role: 'Chief Financial Officer'),
    ],
  ),
  'TCS': CompanyProfile(
    legalName: 'Tata Consultancy Services Limited',
    industry: 'Information Technology Services',
    registeredOffice:
        '9th Floor, Nirmal Building, Nariman Point, Mumbai, Maharashtra 400021',
    corporateIdentityNumber: 'L22210MH1995PLC084781',
    website: 'www.tcs.com',
    email: 'investor.relations@tcs.com',
    phone: '+91 22 6778 9595',
    directors: [
      CompanyPerson(name: 'N. Chandrasekaran', role: 'Chairman'),
      CompanyPerson(name: 'K. Krithivasan', role: 'CEO & MD'),
      CompanyPerson(name: 'Aarthi Subramanian', role: 'Executive Director'),
    ],
    management: [
      CompanyPerson(name: 'K. Krithivasan', role: 'CEO & MD'),
      CompanyPerson(name: 'Aarthi Subramanian', role: 'President & COO'),
      CompanyPerson(name: 'Samir Seksaria', role: 'Chief Financial Officer'),
    ],
  ),
  'INFY': CompanyProfile(
    legalName: 'Infosys Limited',
    industry: 'Information Technology Services',
    registeredOffice:
        'Electronics City, Hosur Road, Bengaluru, Karnataka 560100',
    corporateIdentityNumber: 'L85110KA1981PLC013115',
    website: 'www.infosys.com',
    email: 'investors@infosys.com',
    phone: '+91 80 2852 0261',
    directors: [
      CompanyPerson(name: 'Nandan M. Nilekani', role: 'Chairman'),
      CompanyPerson(name: 'Salil Parekh', role: 'CEO & MD'),
      CompanyPerson(name: 'D. Sundaram', role: 'Lead Independent Director'),
    ],
    management: [
      CompanyPerson(name: 'Salil Parekh', role: 'CEO & MD'),
      CompanyPerson(name: 'Jayesh Sanghrajka', role: 'Chief Financial Officer'),
      CompanyPerson(name: 'Inderpreet Sawhney', role: 'Chief Legal Officer'),
    ],
  ),
  'HDFCBANK': CompanyProfile(
    legalName: 'HDFC Bank Limited',
    industry: 'Private Sector Bank',
    registeredOffice:
        'HDFC Bank House, Senapati Bapat Marg, Lower Parel, Mumbai, Maharashtra 400013',
    corporateIdentityNumber: 'L65920MH1994PLC080618',
    website: 'www.hdfcbank.com',
    email: 'shareholder.grievances@hdfcbank.com',
    phone: '+91 22 6652 1000',
    directors: [
      CompanyPerson(name: 'Atanu Chakraborty', role: 'Part-time Chairman'),
      CompanyPerson(name: 'Sashidhar Jagdishan', role: 'MD & CEO'),
      CompanyPerson(name: 'Bhavesh Zaveri', role: 'Executive Director'),
    ],
    management: [
      CompanyPerson(name: 'Sashidhar Jagdishan', role: 'MD & CEO'),
      CompanyPerson(name: 'Kaizad Bharucha', role: 'Deputy MD'),
      CompanyPerson(
        name: 'Srinivasan Vaidyanathan',
        role: 'Chief Financial Officer',
      ),
    ],
  ),
  'ICICIBANK': CompanyProfile(
    legalName: 'ICICI Bank Limited',
    industry: 'Private Sector Bank',
    registeredOffice:
        'ICICI Bank Tower, Near Chakli Circle, Old Padra Road, Vadodara, Gujarat 390007',
    corporateIdentityNumber: 'L65190GJ1994PLC021012',
    website: 'www.icicibank.com',
    email: 'investor@icicibank.com',
    phone: '+91 22 2653 1414',
    directors: [
      CompanyPerson(name: 'Pradeep Kumar Sinha', role: 'Chairman'),
      CompanyPerson(name: 'Sandeep Bakhshi', role: 'MD & CEO'),
      CompanyPerson(name: 'Rakesh Jha', role: 'Executive Director'),
    ],
    management: [
      CompanyPerson(name: 'Sandeep Bakhshi', role: 'MD & CEO'),
      CompanyPerson(name: 'Rakesh Jha', role: 'Executive Director'),
      CompanyPerson(name: 'Anindya Banerjee', role: 'Chief Financial Officer'),
    ],
  ),
  'SBIN': CompanyProfile(
    legalName: 'State Bank of India',
    industry: 'Public Sector Bank',
    registeredOffice:
        'State Bank Bhavan, Madame Cama Road, Nariman Point, Mumbai, Maharashtra 400021',
    corporateIdentityNumber: 'L93000MH1955PLC009386',
    website: 'www.sbi.co.in',
    email: 'investor.complaints@sbi.co.in',
    phone: '+91 22 2274 0841',
    directors: [
      CompanyPerson(name: 'C. S. Setty', role: 'Chairman'),
      CompanyPerson(name: 'Ashwini Kumar Tewari', role: 'Managing Director'),
      CompanyPerson(name: 'Vinay M. Tonse', role: 'Managing Director'),
    ],
    management: [
      CompanyPerson(name: 'C. S. Setty', role: 'Chairman'),
      CompanyPerson(name: 'Rama Mohan Rao Amara', role: 'Managing Director'),
      CompanyPerson(
        name: 'Kameshwar Rao Kodavanti',
        role: 'Chief Financial Officer',
      ),
    ],
  ),
  'ITC': CompanyProfile(
    legalName: 'ITC Limited',
    industry: 'Diversified Consumer Goods',
    registeredOffice:
        'Virginia House, 37 J. L. Nehru Road, Kolkata, West Bengal 700071',
    corporateIdentityNumber: 'L16005WB1910PLC001985',
    website: 'www.itcportal.com',
    email: 'isc@itc.in',
    phone: '+91 33 2288 9371',
    directors: [
      CompanyPerson(name: 'Sanjiv Puri', role: 'Chairman & MD'),
      CompanyPerson(name: 'Hemant Malik', role: 'Whole-time Director'),
      CompanyPerson(name: 'Sumant Bhargavan', role: 'Whole-time Director'),
    ],
    management: [
      CompanyPerson(name: 'Sanjiv Puri', role: 'Chairman & MD'),
      CompanyPerson(name: 'Supratim Dutta', role: 'Chief Financial Officer'),
      CompanyPerson(name: 'Rajendra Kumar Singhi', role: 'Company Secretary'),
    ],
  ),
  'LT': CompanyProfile(
    legalName: 'Larsen & Toubro Limited',
    industry: 'Engineering & Construction',
    registeredOffice:
        'L&T House, N. M. Marg, Ballard Estate, Mumbai, Maharashtra 400001',
    corporateIdentityNumber: 'L99999MH1946PLC004768',
    website: 'www.larsentoubro.com',
    email: 'infodesk@larsentoubro.com',
    phone: '+91 22 6752 5656',
    directors: [
      CompanyPerson(name: 'S. N. Subrahmanyan', role: 'Chairman & MD'),
      CompanyPerson(name: 'R. Shankar Raman', role: 'Whole-time Director'),
      CompanyPerson(name: 'Subramanian Sarma', role: 'Whole-time Director'),
    ],
    management: [
      CompanyPerson(name: 'S. N. Subrahmanyan', role: 'Chairman & MD'),
      CompanyPerson(name: 'R. Shankar Raman', role: 'President & CFO'),
      CompanyPerson(name: 'Subramanian Sarma', role: 'Deputy MD & President'),
    ],
  ),
  'BHARTIARTL': CompanyProfile(
    legalName: 'Bharti Airtel Limited',
    industry: 'Telecommunication Services',
    registeredOffice:
        'Airtel Center, Plot No. 16, Udyog Vihar Phase IV, Gurugram, Haryana 122015',
    corporateIdentityNumber: 'L74899HR1995PLC095967',
    website: 'www.airtel.in',
    email: 'compliance.officer@bharti.in',
    phone: '+91 124 422 2222',
    directors: [
      CompanyPerson(name: 'Sunil Bharti Mittal', role: 'Chairman'),
      CompanyPerson(name: 'Gopal Vittal', role: 'Executive Vice Chairman'),
      CompanyPerson(name: 'Shishir Priyadarshi', role: 'Independent Director'),
    ],
    management: [
      CompanyPerson(name: 'Shashwat Sharma', role: 'MD & CEO'),
      CompanyPerson(name: 'Gopal Vittal', role: 'Executive Vice Chairman'),
      CompanyPerson(name: 'Soumen Ray', role: 'Chief Financial Officer'),
    ],
  ),
  'AXISBANK': CompanyProfile(
    legalName: 'Axis Bank Limited',
    industry: 'Private Sector Bank',
    registeredOffice:
        'Trishul, 3rd Floor, Opp. Samartheshwar Temple, Law Garden, Ellisbridge, Ahmedabad, Gujarat 380006',
    corporateIdentityNumber: 'L65110GJ1993PLC020769',
    website: 'www.axisbank.com',
    email: 'shareholders@axisbank.com',
    phone: '+91 22 2425 2525',
    directors: [
      CompanyPerson(name: 'N. S. Vishwanathan', role: 'Non-Executive Chairman'),
      CompanyPerson(name: 'Amitabh Chaudhry', role: 'MD & CEO'),
      CompanyPerson(name: 'Rajiv Anand', role: 'Deputy Managing Director'),
    ],
    management: [
      CompanyPerson(name: 'Amitabh Chaudhry', role: 'MD & CEO'),
      CompanyPerson(name: 'Rajiv Anand', role: 'Deputy Managing Director'),
      CompanyPerson(name: 'Puneet Sharma', role: 'Chief Financial Officer'),
    ],
  ),
};
