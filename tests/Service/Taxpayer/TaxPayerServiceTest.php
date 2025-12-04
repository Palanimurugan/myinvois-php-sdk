<?php

/**
 * @copyright Copyright (c) 2024 Sean Kau (kliensheng2020@gmail.com)
 * @license https://github.com/klsheng/myinvois-php-sdk/blob/main/LICENSE
 */

namespace Klsheng\Myinvois\Tests\Service\Taxpayer;

use PHPUnit\Framework\TestCase;
use Klsheng\Myinvois\MyInvoisClient;
use Klsheng\Myinvois\Service\Taxpayer\TaxPayerService;

class TaxPayerServiceTest extends TestCase
{
    /**
     * @covers \Klsheng\Myinvois\Service\AbstractService
     * @covers \Klsheng\Myinvois\Service\Taxpayer\TaxPayerService
     */
    public function testValidateTaxPayerTinBuildsQuery()
    {
        $mockResponse = [
            'tinStatus' => 'valid',
        ];

        $mockClient = $this->createMock(MyInvoisClient::class);
        $mockClient
            ->expects($this->once())
            ->method('request')
            ->with(
                'GET',
                'https://preprod-api.myinvois.hasil.gov.my/api/v1.0/taxpayer/validate/1234567890?idType=NRIC&idValue=990101015432'
            )
            ->willReturn($mockResponse);

        $service = new TaxPayerService($mockClient);
        $response = $service->validateTaxPayerTin('1234567890', 'NRIC', '990101015432');

        $this->assertEquals($mockResponse, $response);
    }

    /**
     * @covers \Klsheng\Myinvois\Service\AbstractService
     * @covers \Klsheng\Myinvois\Service\Taxpayer\TaxPayerService
     */
    public function testSearchTaxPayerTinSkipsEmptyParameters()
    {
        $mockResponse = [
            'searchStatus' => 'not-found',
        ];

        $mockClient = $this->createMock(MyInvoisClient::class);
        $mockClient
            ->expects($this->once())
            ->method('request')
            ->with(
                'GET',
                'https://preprod-api.myinvois.hasil.gov.my/api/v1.0/taxpayer/search/tin'
            )
            ->willReturn($mockResponse);

        $service = new TaxPayerService($mockClient);
        $response = $service->searchTaxPayerTin();

        $this->assertEquals($mockResponse, $response);
    }
}
