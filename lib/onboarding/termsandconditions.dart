import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class TermsAndConditions extends StatelessWidget {
  var data =
      '''<h5><strong><span style="font-family:inherit;color:rgb(1,35,64);font-weight:bold;font-size:16px;">&nbsp;</span></strong><span style="font-family:Cambria;color:rgb(36,63,97);font-size:15px;">READ THIS SECTION BEFORE USING THE PRODUCT. &nbsp;</span></h5>
<p><br></p>
<p><span style="font-family:Calibri;font-size:15px;">Software License Agreement</span></p>
<p><span style="font-family:Calibri;font-size:15px;">Hawks E-Accounting and Consultancy Private Limited&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">This is a legal agreement between yourselves (an individual, company, trust, government company, government department or any other legal entity), the purchaser of the application described hereunder, hereinafter referred to as the LICENSEE, on the one part, and Hawks E-Accounting and Consultancy Private Limited , Registered office &ldquo;</span><span style="font-family:'Times New Roman';color:rgb(1,35,64);font-size:13px;">PLOT NO. A-41, K.NO. 1212, HAYAT ENCLAVE LONI, UP-201102</span><span style="font-family:Calibri;font-size:15px;">&rdquo; hereinafter referred to as the COMPANY, on the other part. By installing the application/software described below, you are agreeing to be bound by the terms of this agreement. If you do not agree to the terms of this agreement, promptly return &nbsp;completely. (don&rsquo;t install system software and mobile app).&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">1.</span><span style="font-family:Calibri;font-size:15px;">GRANT OF LICENSE: The COMPANY grants to the licensee a non-exclusive right to use one copy of the mobile application and system software which will two way communicate to your exclusive licensed Tally software and their data, hereinafter called the &ldquo;mobile application&rdquo; and &ldquo;system software. &nbsp;The system software is in &apos;use&apos; on a computer (Tally server) when it is loaded into temporary memory (that is RAM) or it is &apos;installed&apos; into permanent memory (Hard Disk) and mobile application is in use on a mobile device(Android and IOS Base) and use by one user. The license is granted only for the use of the purchaser with their licensed Tally software, who is the licensee, and the licensee shall not be allowed to use the software and mobile application for the benefit of anyone other than the licensee. The licensee shall not rent, lease, or otherwise transfer this system software and application and the rights to use to anyone.</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">2.</span><span style="font-family:Calibri;font-size:15px;">COPYRIGHT: The &ldquo;system software and mobile application&rdquo; is owned by Hawks E-Accounting And Consultancy Private Limited &nbsp;Private Limited and is protected by Copyright Laws. Therefore you must treat this system software and mobile application like any other copyright material (e.g. a book or musical recording or other copyright softwares). You shall not copy this system software and mobile application.</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">LIMITED WARRANTY</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">1.</span><span style="font-family:Calibri;font-size:15px;">LIMITED FEATURES &amp; WARRANTY: The COMPANY warrants that before purchase you can take trial on demo Company. If you are satisfied, only then, the software and App features should be purchased. This system software and mobile application will only work when you have got legal license of Tally software. We are providing only facility to use your existing licensed Tally software to anywhere with the help of Android and IOS mobile. System software and mobile app can be used only with the limited features which are available (shown in trial), it can&rsquo;t be changed according as per user&rsquo;s demands.&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">Remark: If you are satisfied with the trial then you can purchase it. We are not committing 100% features like Tally software, we are providing just an extra facility with few features/informations only.&nbsp;</span></p>
<p><span style="font-family:Calibri;font-size:15px;">&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">2.&nbsp;</span><span style="font-family:Calibri;font-size:15px;">ACCURACY OF INFORMATION: Although we may post information, material and content on the Platform based on reliable sources, we do not make any express or implied representation, warranty or guarantee as to the accuracy, validity, reliability or completeness of any such information. The features and services of the Platform are provided on an &ldquo;as is&rdquo; and &ldquo;as available&rdquo; basis. We make no representation or warranty about the validity, accuracy, correctness, reliability of any information provided on or through the Platform.</span></p>
<p><span style="font-family:Calibri;font-size:15px;">&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">3.</span><span style="font-family:Calibri;font-size:15px;">APP WORKING &amp; CUSTOMER DATA LIABILITY: This mobile application is working when you have got original license of tally. System software will be installed in your Tally server machine and mobile application will be installed in your Android or IOS mobile. Our system software will communicate with your Tally data (two way). It will always synchronize your Tally data from company server with data storage as general process and revers push this data into your mobile &nbsp;or your tally licensed server as and when you required or according to data sync schedule.</span></p>
<p><span style="font-family:Calibri;font-size:15px;">&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">4.</span><span style="font-family:Calibri;font-size:15px;">FURTHER SUPPORT WARRANTY: The Company will provide only and only telephonic support up to subscription valid and same you have got valid subscription of Tally software. Any kind of onsite support will never provide.&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">&nbsp;</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">5.</span><span style="font-family:Calibri;font-size:15px;">NO LIABILITY FOR CONSEQUENTIAL DAMAGES: The COMPANY and its suppliers under no circumstances shall be liable for any damages whatsoever (including, without limitation, damages for loss of business profit, business interruption, loss of business information/data, or any other monetary or non-monetary loss) arising out of the use or the inability to use this system software and mobile application, even if the COMPANY has been advised of the possibility of such damages.</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">6.</span><span style="font-family:Calibri;font-size:15px;">APPLICATION OF support: The support is applicable if, and only if, the licensee has completed the activation process by logging in license for the software, and the registration information of the licensee has been received and acknowledged payment detail by the COMPANY. Otherwise the support shall not be applied.&nbsp;</span></p>
<p><span style="font-family:Calibri;font-size:15px;">JURISDICTION</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">In the event of any dispute whatsoever arising between the parties in any way connected with the interpretation or implementation of any term of this agreement, or in any way connected with the use or inability to use the SOFTWARE or any other services of the COMPANY, connected with the SOFTWARE, the same shall be referred to the sole arbitration or a person to be appointed by the COMPANY, and the decision of the arbitrator will be final and binding on all parties. The arbitration proceedings shall always be held in the City of Delhi, India. All disputes whatsoever that may arise shall be governed and construed in accordance with the laws prevailing in the City of Delhi, India. Only competent courts within the City of Delhi, India shall have jurisdiction in this regard.</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">If you have any question or clarification concerning this LICENSE, please contact in writing for customer service/support cell:</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">Agree: Before purchasing Hawks E-Accounting And Consultancy Private Limited&rsquo;s Android mobile application, I have read and understood all above terms and I am fully agreed.</span></p>
<p style="text-align:justify;"><span style="font-family:Calibri;font-size:15px;">(If you are not agreed or differ above terms, please don&rsquo;t install system software and mobile application).</span></p>
<p><span style="font-family:Calibri;font-size:16px;">Third Party Rights</span><span style="font-family:Calibri;font-size:15px;">: No third party shall have any right to enforce any terms contained herein.</span></p>
<p><span style="font-family:Calibri;font-size:15px;">&nbsp;</span></p>
<p><span style="font-family:Calibri;font-size:15px;">CUSTOMER SERVICE CELL</span></p>
<p><span style="font-family:Calibri;font-size:15px;">Hawks E-Accounting and Consultancy Private Limited&nbsp;</span></p>
<p><span style="font-family:Calibri;font-size:15px;">&nbsp;</span></p>
<p><span style="font-family:Calibri;font-size:15px;">&nbsp;</span></p>''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Html(data: data),
        ),
      ),
    );
  }
}
